# frozen_string_literal: true

class ConsultationPolicy < ApplicationPolicy
  def index?
    return true if current_user.admin?

    current_user.user?
  end

  def create?
    return current_user.admin? if Rails.configuration.x.asembleo.private_instance

    true
  end

  def update?
    show? && current_user.admin?
  end

  def destroy?
    show? && current_user.admin?
  end

  def show?
    record.id == current_user.consultation_id
  end

  class Scope < Scope
    def resolve
      return scope if current_user.admin?

      scope.where(id: current_user.consultation_id)
    end
  end
end
