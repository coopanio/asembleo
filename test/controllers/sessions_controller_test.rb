# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token, :params

  setup do
    @token = create(:token)
    @params = { session: { identifier: token.to_s } }
  end

  subject { post sessions_url, params: }

  test 'should create session' do
    subject

    assert_response :redirect
    assert_equal token.id, session[:identity_id]
  end

  test 'should create session with aliased token' do
    aliased_token = Faker::PhoneNumber.cell_phone
    @params = { session: { identifier: aliased_token } }

    token.update!(alias: Token.sanitize(aliased_token))

    subject

    assert_response :redirect
    assert_equal token.id, session[:identity_id]
  end

  test 'should fail on deleted token' do
    token.destroy!
    subject

    assert_response :redirect
  end

  test 'should autologin' do
    get "#{sessions_url}/#{token.to_hash}/login"

    assert_response :redirect
    assert_equal token.id, session[:identity_id]
  end
end
