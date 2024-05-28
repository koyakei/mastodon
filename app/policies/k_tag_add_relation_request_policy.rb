# frozen_string_literal: true

class KTagAddRelationRequestPolicy < KTagPolicy
  def approve?(target_account_id)
    current_account&.user.id == record.target_account_id
  end

  def deny?(target_account_id)
    current_account&.user.id == record.target_account_id
  end

  def destroy?
    current_account&.user.id == record.requester_id
  end

end

