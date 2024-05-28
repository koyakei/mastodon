# frozen_string_literal: true

class KTagAddRelationRequestPolicy < KTagPolicy
  def approve?
    current_account&.user.id == record.k_tag_relation.account_id
  end

  def deny?
    current_account&.user.id == record.k_tag_relation.account_id
  end

  def destroy?
    current_account&.user.id == record.requester_id
  end

end

