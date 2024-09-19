# frozen_string_literal: true

require 'test_helper'

class ImportQuestionsTest < ActionDispatch::IntegrationTest
  attr_reader :consultation

  setup do
    @consultation = create(:consultation)
  end

  subject { ImportQuestions.call(content:, consultation:) }

  test 'should import questions' do
    subject

    assert_equal 3, Question.count
    assert_equal 9, Option.count

    question = Question.first
    assert_equal "## What is the capital of France?\n\nText before question\n\nMultiple lines can be present", question.description
    assert_equal consultation, question.consultation
    assert_equal %w(Paris London Berlin), question.options.map(&:value)
  end

  private

  def content
    <<~CONTENT
      ## What is the capital of France?
      Text before question

      Multiple lines can be present

      - Paris
      - London
      - Berlin

      ## What is the capital of Germany?

      - Barcelona
      - Rome
      - Berlin

      ## What is the capital of Spain?

      - Madrid
      - Paris
      - Barcelona
    CONTENT
  end
end
