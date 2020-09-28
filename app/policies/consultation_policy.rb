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
    record == token.consultation
  end

  class Scope < Scope
    def resolve
      scope.where(id: token.consultation)
    end
  end
end
