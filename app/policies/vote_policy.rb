# frozen_string_literal: true

class VotePolicy < ApplicationPolicy
  def create?
    current_user.voter?
  end
end
