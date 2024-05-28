class Api::V1::KTagDeleteRelationRequesController < Api::BaseController
  include Authorization

  before_action :set_api_v1_k_tag_delete_relation_request, only: %i[ show approve deny destroy ]
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :approve, :deny, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :approve, :deny, :destroy]
  before_action :check_statuses_limit, only: [:index]
  before_action :require_user!, except:      [:index, :show]
   # This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  CONTEXT_LIMIT = 4_096

  # GET /api/v1/k_tag_add_relation_reques
  def index
    @api_v1_k_tag_add_relation_requests = KTagDeleteRelationReque.all
  end

  # GET /api/v1/k_tag_add_relation_reques/1
  def show
  end

  # POST /api/v1/k_tag_add_relation_reques
  def create
    api_v1_k_tag_delete_relation_request = KTagDeleteRelationReque.new(api_v1_k_tag_add_relation_request_params)
    if api_v1_k_tag_delete_relation_request.save
      render json: api_v1_k_tag_delete_relation_request
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    authorize @api_v1_k_tag_delete_relation_request, :approve?
    # already_created?
    if @k_tag_relation.valid? ## bug not unique check only 
      ActiveRecord::Base.transaction do
        @api_v1_k_tag_delete_relation_request.update(request_status: :approve, review_comment: params[:review_comment]) 
        @k_tag_relation.save(account: account, k_tag: k_tag, status: status)
        LocalNotificationWorker.perform_async(current_user.account_id,
        @api_v1_k_tag_delete_relation_request.requester_id, 'KTagDeleteRelationRequest', 'k_tag_appprove_delete_relation_request')

        render json: api_v1_k_tag_delete_relation_request
      rescue ActiveRecord::RecordInvalid => exception
        render :edit, status: :unprocessable_entity
      end
    else
      alredy_requested = KTagAddRelationRequest.where(
        account_id: params[:account_id], k_tag: params[:k_tag_id], status_id: paarams[:status_id])
      alredy_requested.update_all(request_status: :approve)
      render json: @k_tag_relation
    end
  end

  def deny
    authorize @api_v1_k_tag_delete_relation_request, :deny?
    if api_v1_k_tag_delete_relation_request.update(request_status: :deny, review_comment: paarams[:review_comment])
      LocalNotificationWorker.perform_async(current_user.account_id,
      @api_v1_k_tag_delete_relation_request.requester_id, 'KTagDeleteRelationRequest', 'k_tag_deny_delete_relation_request')
      render json: api_v1_k_tag_delete_relation_request
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/k_tag_add_relation_reques/1
  def destroy
    authorize @api_v1_k_tag_delete_relation_request, :destroy?
    api_v1_k_tag_delete_relation_request.destroy!
    redirect_to api_v1_k_tag_add_relation_reques_url, notice: "K tag add relation reque was successfully destroyed.", status: :see_other
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_k_tag_delete_relation_request
      @api_v1_k_tag_delete_relation_request = KTagDeleteRelationRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_k_tag_delete_relation_request_params
      params.petmit( :status_id, :k_tag_relation_id, :request_comment, :review_comment)
    end
end
