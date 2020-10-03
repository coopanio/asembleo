# frozen_string_literal: true

require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test 'should load front page' do
    get root_path

    assert_response :success
  end
end
