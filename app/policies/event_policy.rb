# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def create?
    current_user.admin?
  end

  def update?
    show? && !current_user.voter?
  end

  def new_tokens?
    create_tokens?
  end

  def update_token?
    create_tokens?
  end

  def create_tokens?
    show? && !current_user.voter?
  end

  def next_question?
    show? && current_user.voter?
  end

  def destroy?
    show? && current_user.admin?
  end

  def show?
    record.consultation_id == current_user.consultation_id
  end

  class Scope < Scope
    def resolve
      consultation_id = current_user.consultation_id

      scope.where(consultation_id:)
    end
  end
end
