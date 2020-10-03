# frozen_string_literal: true

require 'test_helper'

class DestinationConcernTest < ActiveSupport::TestCase
  attr_reader :consultation, :token

  class Stub
    include DestinationConcern

    attr_reader :token

    def initialize(token)
      @token = token
    end
  end

  setup do
    @consultation = create(:consultation)
    @token = create(:token, consultation: consultation)
  end

  subject { Stub.new(token).send(:active_question) }

  test 'should return no next question' do
    assert subject.blank?
  end

  test 'should return no next question (all in draft status)' do
    create(:question, consultation: consultation)

    assert subject.blank?
  end

  test 'should return the first open question' do
    question = create(:question, consultation: consultation, status: :opened)
    create(:events_question, question: question, status: :opened)

    assert subject.present?
    assert_equal subject.id, question.id
  end

  test 'should return the first open question (second)' do
    event = create(:event)
    questions = %i[closed opened draft].map do |status|
      init_questions(status, event)
    end

    assert subject.present?
    assert_equal subject.id, questions.second.id
  end

  test 'should return the first un-voted and open question (third)' do
    event = create(:event)
    questions = %i[closed opened opened draft].map do |status|
      init_questions(status, event)
    end
    create(:receipt, token: token, question: questions.first)
    create(:receipt, token: token, question: questions.second)

    assert subject.present?
    assert_equal subject.id, questions.third.id
  end

  private

  def init_questions(status, event)
    question = create(:question, consultation: consultation, status: status)
    event_status = status == :draft ? :closed : status
    create(:events_question, question: question, event: event, status: event_status)
    question
  end
end
