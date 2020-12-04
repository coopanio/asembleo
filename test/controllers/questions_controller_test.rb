# frozen_string_literal: true

require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :question, :values, :weights

  setup do
    @question = create(:question)
    create(:option, question: question, value: 'yes')
    create(:option, question: question, value: 'no')
    event = create(:event, consultation: question.consultation)
    @values = %w[yes yes no yes no yes]
    @weights = %w[1.0 1.0 0.5 1.0 1.0 1.0]

    values.size.times do |i|
      token = create(:token, event: event, consultation: question.consultation, weight: weights[i])

      post sessions_url, params: { token: token.to_hash }
      post votes_url, params: { vote: { question_id: question.id, value: values[i] } }
    end
  end

  subject { question.tally }

  test 'should tally votes' do
    results = subject

    assert_equal 4.0, results['yes']
    assert_equal 1.5, results['no']
  end
end
