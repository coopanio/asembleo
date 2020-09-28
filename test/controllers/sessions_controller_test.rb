# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token, :params

  setup do
    @token = create(:token)
    @params = { token: token.to_hash }
  end

  subject { post sessions_url, params: params }

  test 'should create session' do
    subject

    assert_response :redirect
    assert_equal token.id, session[:token]
  end

  test 'should fail on malformed token' do
    @params = { token: 'unknown' }
    subject

    assert_response 401
  end

  test 'should fail on deleted token' do
    @token.destroy!
    subject

    assert_response 401
  end
end
