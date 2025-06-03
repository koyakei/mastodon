# frozen_string_literal: true

class KTagRelationshipsPresenter
  attr_reader :following_map

  def initialize(k_tags, current_account_id = nil, **options)
    @following_map = if current_account_id.nil?
                       {}
                     else
                       KTagFollow.select(:k_tag_id).where(k_tag_id: k_tags.map(&:id), account_id: current_account_id).each_with_object({}) { |f, h| h[f.k_tag_id] = true }.merge(options[:following_map] || {})
                     end
  end
end
