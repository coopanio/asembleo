# frozen_string_literal: true

class OptionPolicy < ApplicationPolicy
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

  def show?
    record.question.consultation == token.consultation
  end

  class Scope < Scope
    def resolve
      scope.where(consultation: token.consultation)
    end
  end
end
