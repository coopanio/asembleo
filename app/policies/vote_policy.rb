# frozen_string_literal: true

class VotePolicy < ApplicationPolicy
  def create?
    token.voter?
  end
end
