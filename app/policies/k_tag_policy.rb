# frozen_string_literal: true

class KTagPolicy < ApplicationPolicy

  def update?
    owner? || role.can?(:manage_invites)
  end

  def destroy?
    owner? || role.can?(:manage_invites)
  end

  private

  def owner?
    record.account_id == current_user&.id
  end
end
