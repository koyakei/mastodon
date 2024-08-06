# frozen_string_literal: true

class Search < ActiveModelSerializers::Model
  attributes :accounts, :statuses, :hashtags, :k_tags
end
