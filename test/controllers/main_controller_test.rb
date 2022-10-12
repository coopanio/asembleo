# frozen_string_literal: true

require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test 'should load front page' do
    get root_path

    assert_response :success
  end

  test 'should redirect admin to their main page' do
    login_as(:admin)

    get root_path

    assert_response :redirect
  end

  test 'should redirect manager to their main page' do
    login_as(:manager)

    get root_path

    assert_response :redirect
  end

  test 'should redirect voter to their main page' do
    login_as(:voter)

    get root_path

    assert_response :redirect
  end

  private

  def login_as(role)
    event = create(:event)
    token = create(:token, role:, consultation: event.consultation, event:)
    post sessions_url, params: { session: { identifier: token.to_hash } }

    assert_response :redirect
  end
end
