# frozen_string_literal: true

require 'test_helper'

class OptionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token, :question

  setup do
    @token = create(:token, :admin)
    @question = create(:question, consultation: token.consultation)

    post sessions_url, params: { token: token.to_hash }
  end

  test 'should create option' do
    params = { option: { value: 'yes', description: 'Sí' } }

    post(question_options_url(question), params:)

    option = Option.first
    assert_response :redirect
    assert_equal option.value, params[:option][:value]
  end

  test 'should update option' do
    option = create(:option, question:)
    params = { option: { value: 'no' } }

    patch(question_option_url(question, option), params:)

    option = Option.first
    assert_response :redirect
    assert_equal option.value, params[:option][:value]
  end
end
