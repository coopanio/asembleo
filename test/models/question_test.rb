# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  attr_reader :consultation, :token

  setup do
    @consultation = create(:consultation)
    @token = create(:token, consultation: consultation)
  end

  subject { consultation.questions.next(token) }

  test 'should return no next question' do
    assert subject.blank?
  end

  test 'should return no next question (all in draft status)' do
    create(:question, consultation: consultation)
    assert subject.blank?
  end

  test 'should return the first open question' do
    question = create(:question, consultation: consultation, status: :open)
    assert subject.present?
    assert_equal subject.id, question.id
  end

  test 'should return the first open question (second)' do
    questions = %i[closed open draft].map do |status|
      create(:question, consultation: consultation, status: status)
    end

    assert subject.present?
    assert_equal subject.id, questions.second.id
  end

  test 'should return the first un-voted and open question (third)' do
    questions = %i[closed open open draft].map do |status|
      create(:question, consultation: consultation, status: status)
    end
    create(:receipt, token: token, question: questions.first)
    create(:receipt, token: token, question: questions.second)

    assert subject.present?
    assert_equal subject.id, questions.third.id
  end
end
