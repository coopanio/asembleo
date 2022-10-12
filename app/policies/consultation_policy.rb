# frozen_string_literal: true

class ConsultationPolicy < ApplicationPolicy
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
      consultation = current_user.consultation

      scope.where(id: consultation)
    end
  end
end
