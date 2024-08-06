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
  has_many :k_tag_relations
  has_many :statuses, through: :k_tag_relations
  has_many :followers, through: :k_tag_follows, source: :account
  attribute :followers_count,      :integer, default: 0
  attribute :following_count,      :integer, default: 0

  validates :followers_count, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  scope :matches_name, ->(term) { where(arel_table[:name].lower.matches(arel_table.lower("#{sanitize_sql_like(KTag.normalize(term))}%"), nil, true)) } # Search with case-sensitive to use B-tree index
  update_index('k_tags', :self)
  has_many :k_tag_delete_relation_requests

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
      matching_name(name)
    end

    def matching_name(name_or_names)
      names = Array(name_or_names).map { |name| arel_table.lower(normalize(name)) }

      if names.size == 1
        where(arel_table[:name].lower.eq(names.first))
      else
        where(arel_table[:name].lower.in(names))
      end
    end
    def find_or_create_by_names(name_or_names)
      names = Array(name_or_names).map { |str| [normalize(str), str] }.uniq(&:first)

      names.map do |(normalized_name, display_name)|
        tag = matching_name(normalized_name).first || create(name: normalized_name,
                                                             display_name: display_name.gsub(HASHTAG_INVALID_CHARS_RE, ''))

        yield tag if block_given?

        tag
      end
    end

    def search_for(term, limit = 5, offset = 0, options = {})
      stripped_term = term.strip

      query = KTag.matches_name(stripped_term)
      query = query.merge(matching_name(stripped_term).or(where.not(reviewed_at: nil))) if options[:exclude_unreviewed]

      query.order(Arel.sql('length(name) ASC, name ASC'))
           .limit(limit)
           .offset(offset)
    end

    def find_normalized(name)
      matching_name(name).first
    end

    def find_normalized!(name)
      find_normalized(name) || raise(ActiveRecord::RecordNotFound)
    end

    def matching_name(name_or_names)
      names = Array(name_or_names).map { |name| arel_table.lower(normalize(name)) }

      if names.size == 1
        where(arel_table[:name].lower.eq(names.first))
      else
        where(arel_table[:name].lower.in(names))
      end
    end

    def normalize(str)
      HashtagNormalizer.new.normalize(str)
    end
  end

  def validate_name_change
    errors.add(:name, I18n.t('tags.does_not_match_previous_name')) unless name_was.mb_chars.casecmp(name.mb_chars).zero?
  end

  def validate_display_name_change
    unless HashtagNormalizer.new.normalize(display_name).casecmp(name.mb_chars).zero?
      errors.add(:display_name,
                 I18n.t('tags.does_not_match_previous_name'))
    end
  end
end
