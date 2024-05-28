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
  has_one :notification, as: :activity, dependent: :destroy

  validates :k_tag_relation_id,  uniquness: { scope: [:k_tag_id, :status_id, :account_id]  }

  update_index('statuses'){ status }
end
