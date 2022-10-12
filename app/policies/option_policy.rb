# frozen_string_literal: true

class OptionPolicy < ApplicationPolicy
  def create?
    current_user.admin?
  end

  def update?
    show? && current_user.admin?
  end

  def destroy?
    show? && current_user.admin?
  end

  def show?
    record.question.consultation == current_user.consultation
  end

  class Scope < Scope
    def resolve
      scope.where(consultation: current_user.consultation)
    end
  end
end
