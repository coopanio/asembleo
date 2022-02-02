# frozen_string_literal: true

require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :question, :values, :weights

  setup do
    @question = create(:question)
    create(:option, question:, value: 'yes')
    create(:option, question:, value: 'no')
    event = create(:event, consultation: question.consultation)
    @values = %w[yes yes no yes no yes]
    @weights = %w[1.0 1.0 0.5 1.0 1.0 1.0]

    values.size.times do |i|
      token = create(:token, event:, consultation: question.consultation, weight: weights[i])

      post sessions_url, params: { token: token.to_hash }
      post votes_url, params: { vote: { question_id: question.id, value: values[i] } }
    end
  end

  subject { question.tally }

  test 'should tally votes' do
    results = subject

    assert_in_delta(4.0, results['yes'])
    assert_in_delta(1.5, results['no'])
    assert_in_delta(5.5, results['_meta']['total_votes'])
  end
end
