# == Schema Information
#
# Table name: k_tag_trading_histories
#
#  id          :bigint(8)        not null, primary key
#  k_tag_id    :bigint(8)        not null
#  account_id  :bigint(8)        not null
#  status_id   :bigint(8)        not null
#  trade_count :integer          default(1), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class KTagTradingHistory < ApplicationRecord

  belongs_to :account
  belongs_to :k_tag
  belongs_to :status
  validates :trade_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -1 }
end
