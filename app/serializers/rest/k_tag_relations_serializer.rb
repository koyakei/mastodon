# frozen_string_literal: true

class REST::KTagRelatiosSerializer < ActiveModel::Serializer

  # attribute :following, if: :current_user?
  # attributes :id,:k_tag_id, :status_id, :k_tag_delete_relation_requests
  
  # has_one :account, serializer: REST::AccountSerializer
  # has_one :k_tag, serializer: REST::KTagSerializer
  attribute :added_k_tag_relation_list, each_serializer: REST::AddedKTagRelation
  attribute :adding_k_tag_relation_requested_list
  attribute :deleting_k_tag_relation_requested_list
  # attribute :owned_k_tag_delete_relation_request, if: :k_tag_delete_relation_request?
  # attribute :is_owned ##tag and relation is owned by yourslef bool

  def added_k_tag_relation_list
    object.k_tag_relations
  end
  def adding_k_tag_relation_requested_list
    []
    # object.k_tag_add_relation_requests.owned_requests(current_user.account_id)
  end
  def deleting_k_tag_relation_requested_list
    []
    # object.k_tag_delete_relation_requests.owned_requests(current_user.account_id)
  end

end

class REST::AddedKTagRelation < ActiveModel::Serializer
  attributes :id, :k_tag_id, :status_id,:account_id, :is_owned

  belongs_to :k_tag 

  has_many :k_tag_delete_relation_requests

  def is_owned
    current_user.account_id == object.account_id
  end
end

class REST::AddingKTagRelationRequested < ActiveModel::Serializer
  attributes :id,:k_tag_id, :status_id,:account_id, :is_owned

  belongs_to :k_tag 
  
  def is_owned
    current_user.account_id == object.account_id
  end

  def current_user?
    !current_user.nil?
  end
end