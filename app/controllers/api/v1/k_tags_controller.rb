class Api::V1::KTagsController < Api::BaseController
  include Authorization

  before_action :set_k_tag, only: %i[ show ]
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:follows' }, except: :show
  before_action :require_user!, except: :show

  override_rate_limit_headers :follow, family: :follows

  # This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  CONTEXT_LIMIT = 4_096


  # GET /k_tags/1
  def show
    render json: @k_tag, serializer: REST::KTagSerializer
  end

  def follow
    TagFollow.create_with(rate_limit: true).find_or_create_by!(tag: @tag, account: current_account)
    render json: @tag, serializer: REST::TagSerializer
  end

  def unfollow
    TagFollow.find_by(account: current_account, tag: @tag)&.destroy!
    TagUnmergeWorker.perform_async(@tag.id, current_account.id)
    render json: @tag, serializer: REST::TagSerializer
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_k_tag
      @k_tag = KTag.find_by(name: k_tag_params[:id])
    end

    # Only allow a list of trusted parameters through.
    def k_tag_params
      params.permit(:id, :name, :description, :account_id, :following_count, :ids)
    end

    def check_statuses_limit
      raise(Mastodon::ValidationError) if k_tag_ids.size > DEFAULT_STATUSES_LIMIT
    end
    def k_tag_ids
      Array(k_tag_params[:ids]).uniq.map(&:to_i)
    end
end
