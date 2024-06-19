# frozen_string_literal: true

class REST::KTagAddRelationRequestSerializer < ActiveModel::Serializer

  attributes  :id, :account, :status_id, :k_tag_id, :k_tag, :is_owned, :account_id

  belongs_to :account, serializer: REST::AccountSerializer
  belongs_to :k_tag

  def is_owned
    current_user.account_id == account_id
  end
end
