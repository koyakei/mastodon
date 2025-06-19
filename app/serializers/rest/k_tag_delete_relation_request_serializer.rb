# frozen_string_literal: true

class REST::KTagDeleteRelationRequestSerializer < ActiveModel::Serializer
  attributes :id, :k_tag_relation_id, :requester_id, :is_owned

  belongs_to :requester, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end

  def requester_id
    object.requester_id.to_s
  end

  def k_tag_relation_id
    object.k_tag_relation_id.to_s
  end

  def is_owned
    current_user.account_id == account_id
  end
end
