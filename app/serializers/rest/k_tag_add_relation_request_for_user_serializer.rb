# frozen_string_literal: true

class REST::KTagAddRelationRequestForUserSerializer < ActiveModel::Serializer
  # Please update `app/javascript/mastodon/api_types/polls.ts` when making changes to the attributes

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
    false
    # current_user&.account_id == object.requester_id
  end

  def decision_status
    KTagAddRelationRequest.decision_status[object.decision_status]
  end
end
