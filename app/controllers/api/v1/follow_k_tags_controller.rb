class Api::V1::FollowKTagsController < Api::BaseController
  include Authorization
  
  before_action :set_api_v1_follow_k_tag, only: %i[ show edit update destroy ]
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :update, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :update, :destroy]
  before_action :require_user!, except:      [:index, :show]
  before_action :check_statuses_limit, only: [:index]
  

  # GET /api/v1/follow_k_tags
  def index
    @api_v1_follow_k_tags = FollowKTag.all
  end

  # GET /api/v1/follow_k_tags/1
  def show
  end

  # POST /api/v1/follow_k_tags
  def create
    @api_v1_follow_k_tag = FollowKTag.new(account_id: current_user&.id, params.permit( :tag_id))

    if @api_v1_follow_k_tag.save
      redirect_to @api_v1_follow_k_tag, notice: "Follow k tag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/follow_k_tags/1
  def destroy
    authorize @k_tag, :destroy?
    @api_v1_follow_k_tag.destroy!
    redirect_to api_v1_follow_k_tags_url, notice: "Follow k tag was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_follow_k_tag
      @api_v1_follow_k_tag = FollowKTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_follow_k_tag_params
      params.permit(:id, :account_id, :tag_id)
    end


end
