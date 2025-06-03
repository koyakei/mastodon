# frozen_string_literal: true

class KTagFeed < PublicKTagFeed
  LIMIT_PER_MODE = 4

  # @param [Tag] tag
  # @param [Account] account
  # @param [Hash] options
  # @option [Enumerable<String>] :any
  # @option [Enumerable<String>] :all
  # @option [Enumerable<String>] :none
  # @option [Boolean] :local
  # @option [Boolean] :local
  # @option [Boolean] :remote
  # @option [Boolean] :only_media
  def initialize(tags, account, options = {})
    @tags = tags
    super(account, options)
  end

  # @param [Integer] limit
  # @param [Integer] max_id
  # @param [Integer] since_id
  # @param [Integer] min_id
  # @return [Array<Status>]
  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    scope = tagged_with_any_scope


    # scope.merge!(tagged_with_any_scope)
    # scope.merge!(tagged_with_all_scope)

    scope.to_a_paginated_by_id(limit, max_id: max_id, since_id: since_id, min_id: min_id)
  end

  private

  def tagged_with_any_scope
    Status.joins(:k_tags).local.where(k_tags: @tags)
  end

  def tagged_with_all_scope
    Status.local.group(:id).k_tagged_with_all(@tags.pluck(:id))
  end

end
