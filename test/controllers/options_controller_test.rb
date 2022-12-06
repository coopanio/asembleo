# frozen_string_literal: true

require 'test_helper'

class OptionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token, :question

  setup do
    @token = create(:token, :admin)
    @question = create(:question, consultation: token.consultation)

    post sessions_url, params: { session: { identifier: token.to_hash } }
  end

  test 'should create option' do
    params = { option: { value: 'yes', description: 'Sí', main: true } }

    post(consultation_question_options_url(token.consultation, question), params:)

    option = Option.first
    assert_response :redirect
    assert_equal option.value, params[:option][:value]
    assert_equal option.description, params[:option][:description]
    assert_equal option.main, params[:option][:main]
  end

  test 'should update option' do
    option = create(:option, question:)
    params = { option: { value: 'no' } }

    patch(consultation_question_option_url(token.consultation, question, option), params:)

    option = Option.first
    assert_response :redirect
    assert_equal option.value, params[:option][:value]
  end
end
