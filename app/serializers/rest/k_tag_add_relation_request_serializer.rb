# frozen_string_literal: true

class REST::KTagAddRelationRequestSerializer < ActiveModel::Serializer

  attributes :id, :is_owned, :decision_status, :k_tag_id, :status_id, :request_comment

  belongs_to :requester, class_name: 'Account', foreign_key: :requester_id ,serializer: REST::AccountSerializer
  belongs_to :k_tag, serializer: REST::KTagSerializer
  # belongs_to :status, serializer: REST::StatusSerializer

  def id
    object.id.to_s
  end

  def k_tag_id
    object.k_tag.id.to_s
  end

  def status_id
    object.status.id.to_s
  end

  def is_owned
    current_user&.account_id == object.requester_id
  end

  def decision_status
    object.read_attribute_for_database(:decision_status)
  end
end
