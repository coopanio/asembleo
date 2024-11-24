# frozen_string_literal: true

class DiagnosticsPolicy < ApplicationPolicy
  def index?
    current_user.admin?
  end
end
