class Api::V1::KTagsController < Api::BaseController
  include Authorization
  
  before_action :set_k_tag, only: %i[ show edit update destroy ]
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :update, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :update, :destroy]
  before_action :require_user!, except:      [:index, :show]
  before_action :check_statuses_limit, only: [:index]

  # This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  CONTEXT_LIMIT = 4_096

  # GET /k_tags
  def index
    @k_tags = KTag.all
    render json: @k_tags, each_serializer: REST::StatusSerializer
  end

  # GET /k_tags/1
  def show
    render json: @k_tag
  end

  # POST /k_tags
  def create
    @k_tag = KTag.new(k_tag_params)

    if @k_tag.save
      redirect_to @k_tag, notice: "K tag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /k_tags/1
  def update
    authorize @k_tag, :update?
    if @k_tag.update(k_tag_params)
      redirect_to @k_tag, notice: "K tag was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /k_tags/1
  def destroy
    authorize @k_tag, :destroy?
    @k_tag.destroy!
    redirect_to k_tags_url, notice: "K tag was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_k_tag
      @k_tag = KTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def k_tag_params
      params.permit(:name, :description, :account_id, :following_count, :ids)
    end

    def check_statuses_limit
      raise(Mastodon::ValidationError) if k_tag_ids.size > DEFAULT_STATUSES_LIMIT
    end
    def k_tag_ids
      Array(k_tag_params[:ids]).uniq.map(&:to_i)
    end
end
