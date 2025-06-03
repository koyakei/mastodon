class Api::V1::FollowedKTagsController < Api::BaseController
  TAGS_LIMIT = 100

  before_action -> { doorkeeper_authorize! :follow, :read, :'read:follows' }
  before_action :require_user!
  before_action :set_results

  after_action :insert_pagination_headers

  def index
    @account_id = params[:account_id] || current_user&.account_id
    render json: @results.map(&:k_tag), each_serializer: REST::KTagSerializer, relationships: KTagRelationshipsPresenter.new(@results.map(&:k_tag), @account_id)
  end

  private

  def set_results
    @results = KTagFollow.where(account_id: @account_id).joins(:k_tag).eager_load(:k_tag).to_a_paginated_by_id(
      limit_param(TAGS_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )
  end

  def next_path
    api_v1_followed_k_tags_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_followed_k_tags_url pagination_params(since_id: pagination_since_id) unless @results.empty?
  end

  def pagination_collection
    @results
  end

  def records_continue?
    @results.size == limit_param(TAGS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end


end
