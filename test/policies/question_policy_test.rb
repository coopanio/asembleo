# frozen_string_literal: true

require 'test_helper'

class QuestionPolicyTest < PolicyAssertions::Test
  attr_reader :token

  setup do
    @token = create(:token)
  end

  test 'should allow access to question to associated token' do
    question = create(:question, consultation: token.consultation)

    assert_permit token, question, :show?
  end

  test 'should allow access to question to not associated token' do
    question = create(:question)

    refute_permit token, question, :show?
  end
end
