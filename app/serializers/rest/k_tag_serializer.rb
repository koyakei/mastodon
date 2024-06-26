# frozen_string_literal: true

class REST::KTagSerializer < ActiveModel::Serializer

  attributes :name, :account, :id , :description, :is_owned

  attribute :following, if: :current_user?

  has_one :account, serializer: REST::AccountSerializer
  
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
    if instance_options && instance_options[:relationships]
      instance_options[:relationships].following_map[object.id] || false
    else
      KTagFollow.exists?(k_tag_id: object.id, account_id: current_user.account_id)
    end
  end

  def is_owned
    current_user? && current_user.account.id == object.account_id
  end

  def current_user?
    !current_user.nil?
  end
end
