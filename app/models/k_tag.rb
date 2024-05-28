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
class KTag < ApplicationRecord

  belongs_to :account
  has_many :k_tag_relation
  has_many :status, through: :k_tag_relations
  validate :followers_count, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  scope :matches_name, ->(term) { where(arel_table[:name].lower.matches(arel_table.lower("#{sanitize_sql_like(KTag.normalize(term))}%"), nil, true)) } # Search with case-sensitive to use B-tree index
  update_index('k_tags', :self)
  
  def search_for(term, limit = 5, offset = 0, options = {})
      stripped_term = term.strip

      query = KTag.matches_name(stripped_term)
      query = query.merge(matching_name(stripped_term))

      query.order(Arel.sql('length(name) ASC, name ASC'))
           .limit(limit)
           .offset(offset)
  end

  def increment_follower_count!
    self.update(followers_count: following_count + 1)
  end

  def decrement_follower_count!
    self.update(followers_count: following_count - 1)
  end

  private 
  class << self
    def normalize(str)
      HashtagNormalizer.new.normalize(str)
    end

    def find_normalized(name)
      matching_name(name).first
    end

    def matching_name(name_or_names)
      names = Array(name_or_names).map { |name| arel_table.lower(normalize(name)) }

      if names.size == 1
        where(arel_table[:name].lower.eq(names.first))
      else
        where(arel_table[:name].lower.in(names))
      end
    end
  end
end
