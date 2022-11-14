# frozen_string_literal: true

require "test_helper"

class QuestionGroupsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token, :params

  setup do
    2.times { create(:question) }
    @token = create(:token, :admin)
    @params = { question_group: { question_ids: Question.pluck(:id) } }

    post sessions_url, params: { session: { identifier: token.to_hash } }
  end

  test 'should create a question group' do
    post question_groups_url, params: params

    assert_equal 1, QuestionGroup.count 
    assert_equal 2, QuestionLink.count
  end

  test 'should not create a question group with less than 2 questions' do
    params[:question_group][:question_ids] = [Question.first.id]

    post question_groups_url, params: params

    assert_response :redirect
    assert_equal 0, QuestionGroup.count 
    assert_equal 0, QuestionLink.count
  end
end
