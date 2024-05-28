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
  belongs_to :requester, clas_name: "Account"
  has_one :notification, as: :activity, dependent: :destroy
end
