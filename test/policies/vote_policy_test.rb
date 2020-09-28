# frozen_string_literal: true

require 'test_helper'

class VotePolicyTest < PolicyAssertions::Test
  test 'voter token can create vote' do
    token = create(:token)
    assert_permit token, Vote, :create?
  end

  test 'admin token cannot create vote' do
    token = create(:token, :admin)
    refute_permit token, Vote, :create?
  end

  test 'manager token cannot create vote' do
    token = create(:token, :manager)
    refute_permit token, Vote, :create?
  end
end
