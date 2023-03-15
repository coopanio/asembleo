# frozen_string_literal: true

class OptionPolicy < ApplicationPolicy
  def create?
    return false if current_user.blank?

    current_user.admin?
  end

  def update?
    return false if current_user.blank?

    show? && current_user.admin?
  end

  def destroy?
    return false if current_user.blank?

    show? && current_user.admin?
  end

  def show?
    return false if current_user.blank?

    record.question.consultation_id == current_user.consultation_id
  end

  class Scope < Scope
    def resolve
      scope.where(consultation_id: current_user.consultation_id)
    end
  end
end
