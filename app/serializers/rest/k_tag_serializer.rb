# frozen_string_literal: true

class REST::KTagSerializer < ActiveModel::Serializer

  attributes :name, :id , :description, :is_owned, :account_id

  attribute :following, if: :current_user?

  # has_one :account, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end

  def account_id
    object.account_id.to_s
  end

  def owned_k_tag_delete_relation_request
    object.k_tag_delete_relation_requests.owned_requests(current_user.account_id).first
  end

  def k_tag_delete_relation_request?
    object.k_tag_delete_relation_requests.owned_requests(current_user.account_id).exists?
  end

  def url
    k_tag_url(object)
  end

  def name
    object.name
  end

  def following
    KTagFollow.exists?(k_tag_id: object.id, account_id: current_user.account_id)
  end

  def is_owned
    current_user? && current_user.account.id == object.account_id
  end

  def current_user?
    !current_user.nil?
  end
end
