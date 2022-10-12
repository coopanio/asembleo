# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_user, :record

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user, scope)
      raise Errors::AccessDenied if current_user.blank?

      @current_user = current_user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
