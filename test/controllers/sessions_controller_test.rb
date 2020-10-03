# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token, :params

  setup do
    @token = create(:token)
    @params = { token: token.to_s }
  end

  subject { post sessions_url, params: params }

  test 'should create session' do
    subject

    assert_response :redirect
    assert_equal token.id, session[:token]
  end

  test 'should create session with aliased token' do
    @params = { token: Faker::PhoneNumber.cell_phone }
    @token.update!(alias: Token.sanitize(@params[:token]))

    subject

    assert_response :redirect
    assert_equal token.id, session[:token]
  end

  test 'should fail on deleted token' do
    @token.destroy!
    subject

    assert_response :redirect
  end
end
