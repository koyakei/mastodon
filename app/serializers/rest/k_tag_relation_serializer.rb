# frozen_string_literal: true

class REST::KTagRelationSerializer < ActiveModel::Serializer

  # attribute :following, if: :current_user?
  attributes :id,:k_tag_id, :status_id, :account_id

  has_one :account, serializer: REST::AccountSerializer
  has_one :k_tag, serializer: REST::KTagSerializer
  has_many :k_tag_delete_relation_requests
  # attribute :owned_k_tag_delete_relation_request, if: :k_tag_delete_relation_request?
  attribute :is_owned

  def owned_k_tag_delete_relation_request
    object.k_tag_delete_relation_requests.owned_requests(current_user.account_id).first?
  end
  def id
    object.id.to_s
  end
  def k_tag_id
    object.k_tag_id.to_s
  end

  def status_id
    object.status_id.to_s
  end
  def account_id
    object.account_id.to_s
  end
  def k_tag_delete_relation_request?
    object.k_tag_delete_relation_requests.owned_requests(current_user.account_id).empty?
  end

  def is_owned
    current_user&.account&.id == object.account_id
  end

  def current_user?
    !current_user.nil?
  end
end
