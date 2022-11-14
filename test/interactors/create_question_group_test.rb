# frozen_string_literal: true

require 'test_helper'

class CreateQuestionGroupTest < ActiveSupport::TestCase
  attr_reader :question_ids

  setup do
    @question_ids = [create(:question).id, create(:question).id]
  end

  subject { CreateQuestionGroup.call(question_ids:) }

  test 'creates a question group' do
    subject

    assert_equal 1, QuestionGroup.count
    assert_equal 2, QuestionLink.count
  end
end
