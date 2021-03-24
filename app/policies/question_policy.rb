# frozen_string_literal: true

class QuestionPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    token.admin?
  end

  def edit?
    update?
  end

  def update?
    show? && token.admin?
  end

  def destroy?
    show? && token.admin?
  end

  def open?
    close?
  end

  def tally?
    close?
  end

  def close?
    show? && token.admin?
  end

  def show?
    record.consultation_id == token.consultation_id
  end

  class Scope < Scope
    def resolve
      scope.where(consultation: token.consultation_id)
    end
  end
end
