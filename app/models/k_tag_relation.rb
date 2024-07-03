# == Schema Information
#
# Table name: k_tag_relations
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  k_tag_id   :bigint(8)        not null
#  status_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class KTagRelation < ApplicationRecord
  belongs_to :account
  belongs_to :k_tag
  belongs_to :status
  has_many :k_tag_delete_relation_requests
  scope :k_tag_delete_relation_requests_yourself, -> (account){ where(account_id: account.user_id )}
  validates_uniqueness_of :k_tag_id, scope: [ :status_id, :account_id]

  update_index('statuses'){ status }
  has_many :k_tag_add_relation_requests, ->(k_tag_add_relation_request) { where(status_id: k_tag_add_relation_request.status_id, k_tag_id: k_tag_add_relation_request.k_tag_id)}
end
