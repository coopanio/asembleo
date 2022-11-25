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

    values.each_with_index do |value, i|
      token = create(:token, event:, consultation: question.consultation, weight: weights[i])

      post sessions_url, params: { session: { identifier: token.to_hash } }
      post votes_url, params: { vote: { question.id => { value: [value] } }, question_id: question.id }.stringify_keys
    end
  end

  subject { question.tally }

  test 'should tally votes' do
    results = subject

    assert_in_delta(4.0, results['yes'])
    assert_in_delta(1.5, results['no'])

    meta = results['_meta']
    assert_in_delta(5.5, meta['total_votes'])

    breakdown = meta['breakdown']
    assert_not_nil(breakdown)
    assert_in_delta(4.0, breakdown.dig(1, 'yes'))
    assert_in_delta(1.5, breakdown.dig(1, 'no'))
  end

  test 'should tally votes by event' do
    event = create(:event, consultation: question.consultation)
    values = %w[no no no yes]
    weights = %w[1.0 1.0 1.0 2.0]

    values.each_with_index do |value, i|
      token = create(:token, event:, consultation: question.consultation, weight: weights[i])

      post sessions_url, params: { session: { identifier: token.to_hash } }
      post votes_url, params: { vote: { question.id => { value: [value] } }, question_id: question.id }.stringify_keys
    end

    results = subject

    assert_in_delta(6.0, results['yes'])
    assert_in_delta(4.5, results['no'])

    meta = results['_meta']
    assert_in_delta(10.5, meta['total_votes'])

    breakdown = meta['breakdown']
    assert_not_nil(breakdown)
    assert_in_delta(4.0, breakdown.dig(1, 'yes'))
    assert_in_delta(1.5, breakdown.dig(1, 'no'))

    breakdown = meta['breakdown']
    assert_not_nil(breakdown)
    assert_in_delta(2.0, breakdown.dig(2, 'yes'))
    assert_in_delta(3.0, breakdown.dig(2, 'no'))
  end
end
