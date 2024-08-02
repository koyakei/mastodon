class Api::V1::KTagAddRelationRequestsController < Api::BaseController
  include Authorization

  before_action :set_api_v1_k_tag_add_relation_request, only: %i[show approve deny destroy]
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :approve, :deny, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only: [:create, :approve, :deny, :destroy]
  before_action :require_user!, except: [:index, :show]
  before_action :check_get_limit, only: [:index]

  def index
    @api_v1_k_tag_add_relation_requests = KTagAddRelationRequest.all
  end

  def show
  end

  def create
    ac = KTag.find_by(id: api_v1_k_tag_add_relation_request_params[:k_tag_id]).account_id
    k_tag_add_relation_request = KTagAddRelationRequest.new(api_v1_k_tag_add_relation_request_params.merge(
      requester_id: current_user.account_id,
      target_account_id: ac,
      request_status: :not_reviewed
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
        render json: k_tag_relation.status, status: :created, serializer: REST::StatusSerializer
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: k_tag_relation.errors.full_messages }, status: :unprocessable_entity
      end
    else
      if k_tag_add_relation_request.valid?
        UpdateStatusService.new.call(
            k_tag_add_relation_request.status,
            current_user.account.id,
            k_tag_add_relation_request: k_tag_add_relation_request
          )
        begin
          k_tag_add_relation_request.save!
          LocalNotificationWorker.new.perform(k_tag_add_relation_request.k_tag.account_id,
          k_tag_add_relation_request.id, 'KTagAddRelationRequest', 'k_tag_add_relation_request')
          DistributionWorker.perform_async(k_tag_add_relation_request.status.id)
          render json: k_tag_add_relation_request.status, serializer: REST::StatusSerializer
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: k_tag_add_relation_request.errors.full_messages }, status: :internal_server_error
        end
      else
        render json: { errors: k_tag_add_relation_request.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def approve
    authorize @k_tag_add_relation_request, :approve?
    @k_tag_relation = KTagRelation.new(account_id: current_user.account_id, k_tag: @k_tag_add_relation_request.k_tag, status_id: @k_tag_add_relation_request.status_id)
    if @k_tag_relation.valid?
      ActiveRecord::Base.transaction do
        @k_tag_relation.save!
        @k_tag_add_relation_request.update(request_status: :approved, review_comment: params[:review_comment] || "")
        LocalNotificationWorker.perform_async(@k_tag_add_relation_request.requester_id,
        @k_tag_add_relation_request.id, 'KTagAddRelationRequest', 'k_tag_add_relation_request_approved')
        UpdateStatusService.new.call(
          @k_tag_relation.status,
          current_user.account_id,
          k_tag_add_relation_request: @k_tag_add_relation_request
        )
        render json: @k_tag_add_relation_request, serializer: REST::KTagAddRelationRequestForUserSerializer
      rescue ActiveRecord::RecordInvalid => exception
        render :edit, status: :unprocessable_entity
      end
    else
      already_requested = KTagAddRelationRequest.where(
        target_account_id: current_user.id, k_tag: params[:k_tag_id], status_id: params[:status_id])
        KTagAddRelationRequest.update(request_status: :approved)
      render json: { errors: "already related #{@k_tag_relation.valid?}" }, status: :conflict
    end
  end

  def deny
    authorize @k_tag_add_relation_request, :deny?
    if @k_tag_add_relation_request.update(request_status: :denied, review_comment: params[:review_comment])
      LocalNotificationWorker.perform_async(@api_v1_k_tag_delete_relation_request.requester_id,
                                            @api_v1_k_tag_delete_relation_request.id, 'KTagDeleteRelationRequest', 'k_tag_deny_add_relation_request')

      render json: @k_tag_add_relation_request
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @k_tag_add_relation_request.destroy!
    stream_and_notify
    redirect_to api_v1_k_tag_add_relation_requests_url, notice: "K tag add relation request was successfully destroyed.", status: :see_other
  end

  def check_get_limit
    raise(Mastodon::ValidationError) if ids.size > GET_LIMIT
  end

  private

  def ids
    Array(statuses_params[:ids]).uniq.map(&:to_i)
  end

  def set_api_v1_k_tag_add_relation_request
    @k_tag_add_relation_request = KTagAddRelationRequest.find(params[:id])
  end

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
