# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :token, :record

  def initialize(token, record)
    raise Errors::AccessDenied unless token.present?

    @token = token
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
    attr_reader :token, :scope

    def initialize(token, scope)
      raise Errors::AccessDenied unless token.present?

      @token = token
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
