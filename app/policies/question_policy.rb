# frozen_string_literal: true

class QuestionPolicy < ApplicationPolicy
  def create?
    current_user.admin?
  end

  def edit?
    create?
  end

  def update?
    show? && current_user.admin?
  end

  def destroy?
    show? && current_user.admin?
  end

  def open?
    close?
  end

  def tally?
    close?
  end

  def close?
    show? && current_user.admin?
  end

  def show?
    record.consultation_id == current_user.consultation_id
  end

  class Scope < Scope
    def resolve
      return scope if current_user.consultation_id.nil?

      scope.where(consultation_id: current_user.consultation_id)
    end
  end
end
