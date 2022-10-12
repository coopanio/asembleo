# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :principal, :params

  setup do
    @principal = create(:token)
    @params = { session: { identifier: principal.to_s } }
  end

  subject { post sessions_url, params: }

  test 'should create session' do
    subject

    assert_response :redirect
    assert_equal principal.id, session[:identity_id]
  end

  test 'should create session with aliased token' do
    aliased_token = Faker::PhoneNumber.cell_phone
    @params = { session: { identifier: aliased_token } }

    principal.update!(alias: Token.sanitize(aliased_token))

    subject

    assert_response :redirect
    assert_equal principal.id, session[:identity_id]
  end

  test 'should fail on deleted token' do
    principal.destroy!
    subject

    assert_response :redirect
  end

  test 'should autologin' do
    get "#{sessions_url}/#{principal.to_hash}/login"

    assert_response :redirect
    assert_equal principal.id, session[:identity_id]
  end

  test 'should create session with instance user' do
    @principal = create(:user)
    @params = { session: { identifier: principal.identifier, password: 'wubbalubba' } }

    subject

    assert_response :redirect
    assert_equal principal.id, session[:identity_id]
    assert_equal principal.class.name, session[:identity_type]
  end
end
