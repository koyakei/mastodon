class Api::V1::KTagRelationsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :destroy]
  before_action :require_user!, except:      [:index, :show]
  before_action :set_api_v1_k_tag_relation, only: %i[ show destroy ]


  # GET /api/v1/k_tag_relations
  def index
    @api_v1_k_tag_relations = KTagRelation.all
    render json: @api_v1_k_tag_relations , each_serializer: REST::KTagRelationSerializer
  end

  # GET /api/v1/k_tag_relations/1
  def show
  end

  # POST /api/v1/k_tag_relations
  def create
    authorize  @api_v1_k_tag_relation, create?(KTag.find_by(id: update_create_api_v1_k_tag_relation_params[:k_tag_id]).account_id)
    @api_v1_k_tag_relation = KTagRelation.new(update_create_api_v1_k_tag_relation_params.store(:account_id, current_user&.account_id))
    if @api_v1_k_tag_relation.save
      # 追加した場合でなおかつ現在のタグが二重に追加され得たバア愛

      UpdateStatusService.new.call(
        @api_v1_k_tag_relation.status,
      current_user.account_id,
      k_tag: true
    )
      redirect_to @api_v1_k_tag_relation, notice: "K tag relation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # # PATCH/PUT /api/v1/k_tag_relations/1
  # def update
  #   authorize  @api_v1_k_tag_relation, :update?
  #   if @api_v1_k_tag_relation.update(update_create_api_v1_k_tag_relation_params.store(:account_id, current_user&.account_id))
  #     redirect_to @api_v1_k_tag_relation, notice: "K tag relation was successfully updated.", status: :see_other
  #   else
  #     render :edit, status: :unprocessable_entity
  #   end
  # end

  # DELETE /api/v1/k_tag_relations/1
  def destroy
    authorize  @api_v1_k_tag_relation, :destroy?

    @api_v1_k_tag_relation.destroy!
    redirect_to api_v1_k_tag_relations_url, notice: "K tag relation was successfully destroyed.", status: :see_other
  end

  private
    def destroy?
      @api_v1_k_tag_relation.account_id == current_user&.account_id
    end

    def update?
      @api_v1_k_tag_relation.account_id == current_user&.account_id
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_k_tag_relation
      @api_v1_k_tag_relation = KTagRelation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_k_tag_relation_params
      params.require(:api_v1_k_tag_relation).permit(:account_id, :k_tag_id, :status_id)
    end

    def update_create_api_v1_k_tag_relation_params
      params.require(:api_v1_k_tag_relation).permit(:k_tag_id, :status_id)
    end
end
