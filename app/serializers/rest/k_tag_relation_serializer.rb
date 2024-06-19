# frozen_string_literal: true

class REST::KTagRelationSerializer < ActiveModel::Serializer

  attribute :following, if: :current_user?
  attributes :id,:k_tag_id, :status_id, :k_tag_delete_relation_requests
  
  has_one :account, serializer: REST::AccountSerializer
  has_one :k_tag, serializer: REST::KTagSerializer
  has_many :k_tag_delete_relation_requests
  attribute :owned_k_tag_delete_relation_request, if: :k_tag_delete_relation_request?
  attribute :is_owned ##tag and relation is owned by yourslef bool

  def owned_k_tag_delete_relation_request
    object.k_tag_delete_relation_requests.owned_requests(current_user.account_id).first?
  end

  def k_tag_delete_relation_request?
    object.k_tag_delete_relation_requests.owned_requests(current_user.account_id).empty?
  end

  def is_owned
    current_user.account_id == object.account_id
  end

  def current_user?
    !current_user.nil?
  end
end
