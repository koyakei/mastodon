# == Schema Information
#
# Table name: k_tag_add_relation_requests
#
#  id                :bigint(8)        not null, primary key
#  k_tag_id          :bigint(8)        not null
#  requester_id      :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  status_id         :bigint(8)        not null
#  request_status    :integer          default(0), not null
#  request_comment   :text             default(""), not null
#  review_comment    :text             default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class KTagAddRelationRequest < ApplicationRecord
  belongs_to :k_tag
  belongs_to :target_account, class_name: "Account"
  belongs_to :requester, class_name: "Account"
  belongs_to :status
  has_one :notification, as: :activity, dependent: :destroy
  enum :request_status, {
    not_reviewed: 0,
    approved: 1,
    denied: 2
  }
  scope :owned_requests, ->(account_id) { where(account_id: account_id) }
  validate :unique_not_reviewed_request

  def unique_not_reviewed_request
    if request_status == "not_reviewed" && self.class.where(k_tag_id: k_tag_id, requester_id: requester_id, status_id: status_id, request_status: "not_reviewed").exists?
      errors.add(:base, "A not_reviewed request with the same k_tag_id, requester_id, and status_id already exists.")
    end
  end
end
