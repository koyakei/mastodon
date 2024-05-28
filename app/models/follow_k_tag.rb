# == Schema Information
#
# Table name: follow_k_tags
#
#  id         :bigint(8)        not null, primary key
#  k_tag_id   :bigint(8)        not null
#  account_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class FollowKTag < ApplicationRecord

  include Paginable
  include RelationshipCacheable
  include RateLimitable
  include FollowLimitable

  rate_limit by: :account, family: :follows

  
  belongs_to :k_tag
  belongs_to :account
  validates_uniqueness_of :k_tag_id, scope: :account_id

  has_one :notification, as: :activity, dependent: :destroy

  scope :recent, -> { reorder(id: :desc) }

  def local?
    false # Force uri_for to use uri attribute
  end

  #  隠すのやめた
  # def revoke_request!
  #   FollowRequest.create!(account: account, k_tag: k_tag, show_reblogs: show_reblogs, notify: notify, languages: languages, uri: uri)
  #   destroy!
  # end

  before_validation :set_uri, only: :create
  after_create :increment_cache_counters
  after_destroy :decrement_cache_counters

  private

  def set_uri
    self.uri = ActivityPub::KTagManager.instance.generate_uri_for(self) if uri.nil?
  end

  def increment_cache_counters
    k_tag&.increment_follower_count!(:followers_count)
  end

  def decrement_cache_counters
    k_tag&.decrement_followe_count!(:followers_count)
  end


end
