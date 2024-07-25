class Api::V1::KTagAddRelationRequestsController < Api::BaseController
  include Authorization

  before_action :set_api_v1_k_tag_add_relation_request, only: %i[ show approve deny destroy ]
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :approve, :deny, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :approve, :deny, :destroy]
  before_action :require_user!, except:      [:index, :show]



  before_action :check_get_limit, only: [:index]
   # This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  GET_LIMIT = 4_096


  # GET /api/v1/k_tag_add_relation_reques
  def index
    @api_v1_k_tag_add_relation_requests = KTagAddRelationRequest.all
  end

  # GET /api/v1/k_tag_add_relation_reques/1
  def show
  end

  # POST /api/v1/k_tag_add_relation_reques
  def create
    ac = KTag.find_by(id: api_v1_k_tag_add_relation_request_params[:k_tag_id]).account_id
    k_tag_add_relation_request = KTagAddRelationRequest.new(api_v1_k_tag_add_relation_request_params.merge(
      requester_id: current_user.account_id,
      target_account_id: ac
    ))
    if current_user.account.id == KTag.find_by(id: api_v1_k_tag_add_relation_request_params[:k_tag_id]).account_id
      k_tag_relation = KTagRelation.new(account_id: current_user.account_id, k_tag_id: api_v1_k_tag_add_relation_request_params[:k_tag_id], status_id: api_v1_k_tag_add_relation_request_params[:status_id])
      begin
        k_tag_relation.save!
        UpdateStatusService.new.call(
              k_tag_relation.status,
          current_user.account_id,
          k_tag_relations: k_tag_relation
        )
        # 追加した場合でなおかつ現在のタグが二重に追加され得た場合追加リクエストが自分のものにもかかわらず入ってしまう
        render json: k_tag_relation.status, status: :created, serializer: REST::StatusSerializer
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: k_tag_relation.errors.full_messages }, status: :unprocessable_entity
      end
    else
      if  k_tag_add_relation_request.valid?
        begin
          # k_tag_add_relation_request.save!
          UpdateStatusService.new.call(
            k_tag_add_relation_request.status,
            current_user.account_id,
            k_tag_add_relation_request: k_tag_add_relation_request
          )
          logger.debug k_tag_add_relation_request.status
          render json: k_tag_add_relation_request.status, serializer: REST::StatusSerializer
      rescue ActiveRecord::RecordInvalid => e
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: k_tag_add_relation_request.errors.full_messages }, status: :internal_server_error
        end
      else
        logger.debug k_tag_add_relation_request.errors.full_messages
        render json: { errors: k_tag_add_relation_request.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def approve
    authorize @k_tag_add_relation_request, :approve?
    @k_tag_relation = KTagRelation.new(account_id: current_user.account_id, k_tag: params[:k_tag_id], status_id: paarams[:status_id])
    if @k_tag_relation.valid? ## bug not unique check only
      ActiveRecord::Base.transaction do
        @k_tag_relation.save(account: account, k_tag: k_tag, status: status)
        @k_tag_add_relation_request.update(decision_status: :approved, review_comment: params[:review_comment])
        LocalNotificationWorker.perform_async(@api_v1_k_tag_delete_relation_request.requester_id,
        @api_v1_k_tag_delete_relation_request.id, 'KTagDeleteRelationRequest', 'k_tag_appprove_add_relation_request')
        UpdateStatusService.new.call(
          @k_tag_relation.status,
          current_user.account_id,
          k_tag_add_relation_request: @k_tag_add_relation_request
        )
        render json: @k_tag_add_relation_request
      rescue ActiveRecord::RecordInvalid => exception
        render :edit, status: :unprocessable_entity
      end
    else
      alredy_requested = KTagAddRelationRequest.where(
        account_id: current_user.account_id, k_tag: params[:k_tag_id], status_id: paarams[:status_id])
      alredy_requested.update_all(decision_status: :approved)
      render json: { errors: "already related #{@k_tag_relation.valid?}" }, status: :conflict
    end
  end

  def deny
    authorize @k_tag_add_relation_request, :deny?
    if @k_tag_add_relation_request.update(decision_status: :denied, review_comment: paarams[:review_comment])
      LocalNotificationWorker.perform_async(@api_v1_k_tag_delete_relation_request.requester_id,
      @api_v1_k_tag_delete_relation_request.id, 'KTagDeleteRelationRequest', 'k_tag_deny_add_relation_request')

      render json: @k_tag_add_relation_request
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/k_tag_add_relation_reques/1
  def destroy
    # authorize @k_tag_add_relation_request, :destroy?
    @k_tag_add_relation_request.destroy!
    stream_and_notify
    redirect_to api_v1_k_tag_add_relation_reques_url, notice: "K tag add relation reque was successfully destroyed.", status: :see_other
  end

  def check_get_limit
    raise(Mastodon::ValidationError) if ids.size > GET_LIMIT
  end

  private

  def ids
    Array(statuses_params[:ids]).uniq.map(&:to_i)
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_k_tag_add_relation_request
      @k_tag_add_relation_request = KTagAddRelationRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_k_tag_add_relation_request_params
      params.permit(:account_id, :status_id, :k_tag_id, :request_comment, :review_comment)
    end

    def require_user!
      if !current_user
        render json: { error: 'This method requires an authenticated user' }, status: 422
      elsif !current_user.confirmed?
        render json: { error: 'Your login is missing a confirmed e-mail address' }, status: 403
      elsif !current_user.approved?
        render json: { error: 'Your login is currently pending approval' }, status: 403
      elsif !current_user.functional?
        render json: { error: 'Your login is currently disabled' }, status: 403
      else
        update_user_sign_in
      end
    end
end
