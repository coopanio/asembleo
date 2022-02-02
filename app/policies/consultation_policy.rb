# frozen_string_literal: true

class ConsultationPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    show? && token.admin?
  end

  def destroy?
    show? && token.admin?
  end

  def show?
    record.id == token.consultation_id
  end

  class Scope < Scope
    def resolve
      consultation = token.consultation

      scope.where(id: consultation)
    end
  end
end
