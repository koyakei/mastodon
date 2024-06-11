# frozen_string_literal: true

class KTagAddRelationPolicy < ApplicationPolicy

  def destroy?
    owner? || role.can?(:manage_invites)
  end

  def create?(tag_owner_id)
    record.account_id == tag_owner_id
  end

  private

  def owner?
    record.account_id == current_user&.id
  end
end

