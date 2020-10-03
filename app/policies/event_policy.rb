# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
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
    show? && !token.voter?
  end

  def new_tokens?
    create_tokens?
  end

  def update_token?
    create_tokens?
  end

  def create_tokens?
    show? && !token.voter?
  end

  def next_question?
    show? && token.voter?
  end

  def destroy?
    show? && token.admin?
  end

  def show?
    record.consultation == token.consultation
  end

  class Scope < Scope
    def resolve
      scope.where(consultation: token.consultation)
    end
  end
end
