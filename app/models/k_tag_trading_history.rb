# == Schema Information
#
# Table name: k_tags
#
#  id              :bigint(8)        not null, primary key
#  name            :text
#  description     :text
#  account_id      :bigint(8)        not null
#  following_count :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class KTagTraidingHistory < ApplicationRecord

  belongs_to :account
  belongs_to :k_tag
  belongs_to :status
  validates :trade_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -1 }
end
