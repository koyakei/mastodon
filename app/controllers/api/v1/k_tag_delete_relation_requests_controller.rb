class Api::V1::KTagDeleteRelationRequestsController < Api::BaseController
  include Authorization

  before_action :set_api_v1_k_tag_delete_relation_request, only: %i[ show approve deny destroy ]
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :approve, :deny, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :approve, :deny, :destroy]
  before_action :require_user!, except:      [:index, :show]
  #  This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  CONTEXT_LIMIT = 4_096

  # GET /api/v1/k_tag_add_relation_reques
  def index
    @api_v1_k_tag_add_relation_requests = KTagDeleteRelationRequest.all
  end

  # GET /api/v1/k_tag_add_relation_reques/1
  def show
  end

  # POST /api/v1/k_tag_delete_relation_request
  def create
    logger.debug api_v1_k_tag_delete_relation_request_params[:k_tag_relation_id]
    logger.debug KTagRelation.find_by(id: api_v1_k_tag_delete_relation_request_params[:k_tag_relation_id])
    k_tag_relation = KTagRelation.find_by(id: api_v1_k_tag_delete_relation_request_params[:k_tag_relation_id])
    if k_tag_relation.nil?
      render json: { error: 'KTagRelation not found' }, status: :not_found
    elsif k_tag_relation&.account_id == current_user&.account_id
      # 削除された場合で二重二リクエストが来た場合、自分のものなのに削除リクエストが入る
      if k_tag_relation.discard
        UpdateStatusService.new.call(
          k_tag_relation.status,
        current_user.account_id,
        k_tag: true
      )
      logger.debug k_tag_relation
        # 自分のものを削除できました　レスポンス　http 200 で返すべき　KTagRelation削除メソッドにクライアント側からアクセスするべきなのかも
        render json: k_tag_relation.status, status: :ok, serializer: REST::StatusSerializer
      end
    else
      # 他人の所有しているタグだった場合リクエストを送る　通知
      api_v1_k_tag_delete_relation_request = KTagDeleteRelationRequest.new(api_v1_k_tag_delete_relation_request_params.merge(requester_id: current_user.account_id ))
      if api_v1_k_tag_delete_relation_request.save
        UpdateStatusService.new.call(
          k_tag_relation.status,
          current_user.account_id,
          k_tag: true
        )
        LocalNotificationWorker.perform_async(k_tag_relation&.account_id, api_v1_k_tag_delete_relation_request.id, 'KTagDeleteRelationRequest','k_tag_delete_relation_request')
        render json: k_tag_relation.status, status: :ok, serializer: REST::StatusSerializer
      else
        render json: { errors: api_v1_k_tag_delete_relation_request.errors.full_messages }, status: :conflict
      end
    end
  end

  def approve
    authorize @api_v1_k_tag_delete_relation_request, :approve?
    # already_created?
    if @api_v1_k_tag_delete_relation_request.approved?
      render json: { error: "already approved" }, status: :unprocessable_entity
    else
      k_tag_relation = @api_v1_k_tag_delete_relation_request.k_tag_relation
      if k_tag_relation.discarded?
        render json: {error: "k tag relation alredy discarded"}, status: :unprocessable_entity
      end
      ActiveRecord::Base.transaction do
        # 承認して関係性を削除
        @api_v1_k_tag_delete_relation_request.update(request_status: :approved, review_comment: params[:review_comment] || "")

        k_tag_relation.discard!
        UpdateStatusService.new.call(
          k_tag_relation.status,
          current_user.account_id,
          k_tag: true
        )
        LocalNotificationWorker.perform_async(k_tag_relation.account_id,
        @api_v1_k_tag_delete_relation_request.id , 'KTagDeleteRelationRequest', 'k_tag_appproved_delete_relation_request')
      rescue ActiveRecord::RecordInvalid => exception
        render json: {error: exception},, status: :unprocessable_entity
      end
      render json: @api_v1_k_tag_delete_relation_request, status: :ok
    end
  end

  def deny
    authorize @api_v1_k_tag_delete_relation_request, :deny?
    if @api_v1_k_tag_delete_relation_request.denied?
      render json: { error: "already denied" }, status: :unprocessable_entity
    else
      if @api_v1_k_tag_delete_relation_request.update(request_status: :denied, review_comment: paarams[:review_comment])
        #TODO: 残りのリクエストを全部同じ決定にして処理するの？
        @api_v1_k_tag_delete_relation_request.k_tag_relation.undiscard ## error catch しなくていいの？　過去に一回削除承認しても拒否で戻せるように　押し間違い対応
        LocalNotificationWorker.perform_async(k_tag_relation.account_id,
        @api_v1_k_tag_delete_relation_request.id, 'KTagDeleteRelationRequest', 'k_tag_denied_delete_relation_request')
        UpdateStatusService.new.call(
          @api_v1_k_tag_delete_relation_request.k_tag_relation.status,
          current_user.account_id,
          k_tag: true
        )
        render json: @api_v1_k_tag_delete_relation_request
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  # DELETE /api/v1/k_tag_add_relation_request/1
  def destroy
    authorize @api_v1_k_tag_delete_relation_request, :destroy?
    api_v1_k_tag_delete_relation_request.destroy!
    redirect_to api_v1_k_tag_add_relation_request_url, notice: "K tag add relation reque was successfully destroyed.", status: :see_other
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_k_tag_delete_relation_request
      @api_v1_k_tag_delete_relation_request = KTagDeleteRelationRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_k_tag_delete_relation_request_params
      params.permit( :status_id, :k_tag_relation_id, :request_comment, :review_comment)
    end
end
