# == Schema Information
#
# Table name: k_tag_delete_relation_requests
#
#  id                :bigint(8)        not null, primary key
#  k_tag_relation_id :bigint(8)
#  requester_id      :bigint(8)        not null
#  request_comment   :text             default(""), not null
#  review_comment    :text             default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class KTagDeleteRelationRequest < ApplicationRecord
  belongs_to :k_tag_relation, optional: true
  belongs_to :requester, class_name: "Account"
  has_one :notification, as: :activity, dependent: :destroy
  scope :owned_requests, ->(account_id) { where(account_id: account_id) }
  validates :k_tag_relation_id, uniqueness: { scope: :requester_id }
  around_create {self.update_column(:k_tag_relation_id_backup, self.k_tag_relation_id)}
  enum request_status:{
    not_decided: 0,
    approved: 1,
    denied: 2
  }

  def reviewed?
    !self.not_reviewed?
  end
end
