# frozen_string_literal: true

class REST::KTagDeleteRelationRequestSerializer < ActiveModel::Serializer

  attributes  :id, :account, :status_id, :k_tag_id, :k_tag, :is_owned, :k_tag_delete_relation_request

  belongs_to :account, serializer: REST::AccountSerializer
  belongs_to :k_tag
  has_many :k_tag_delete_relation_requests
  
  def is_owned
    current_user.account_id == account_id
  end

end
