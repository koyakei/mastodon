# frozen_string_literal: true

class KTagAddRelationPolicy < ApplicationPolicy

  def destroy?
    owner? || role.can?(:manage_invites)
  end

  private

  def owner?
    record.account_id == current_user&.id
  end
end

