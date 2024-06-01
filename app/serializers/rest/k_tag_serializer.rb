# frozen_string_literal: true

class REST::KTagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :url, :history

  attribute :following, if: :current_user?

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

  def current_user?
    !current_user.nil?
  end
end
