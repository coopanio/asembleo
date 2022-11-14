# frozen_string_literal: true

class QuestionGroupPolicy < ApplicationPolicy
  def index?
    create?
  end

  def create?
    current_user.admin?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      scope.where(
        id: QuestionLink.joins(:question).where(question: { consultation_id: current_user.consultation_id }).pluck(:question_group_id)
      )
    end
  end
end
