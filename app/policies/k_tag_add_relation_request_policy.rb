# frozen_string_literal: true

class KTagAddRelationRequestPolicy < KTagPolicy
  def approve?
    current_account.id == record.target_account_id
  end

  def deny?
    current_account.id == record.target_account_id
  end

  def destroy?
    current_account.id == record.requester_id
  end
end
