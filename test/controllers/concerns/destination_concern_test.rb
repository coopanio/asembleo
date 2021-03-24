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
    create(:events_question, question: question, consultation: consultation, status: :opened)

    assert subject.present?
    assert_equal subject, question.id
  end

  test 'should return the first open question (second)' do
    event = create(:event)

    questions = %i[closed opened draft].map do |status|
      init_questions(status, event)
    end

    assert subject.present?
    assert_equal subject, questions.second.id
  end

  test 'should return the first un-voted and open question (third)' do
    event = create(:event)
    questions = %i[closed opened opened draft].map do |status|
      init_questions(status, event)
    end

    create(:receipt, token: token, question: questions.first)
    create(:receipt, token: token, question: questions.second)

    assert subject.present?
    assert_equal subject, questions.third.id
  end

  test 'should return the first open question when multiple consultations are active' do
    events = [
      create(:event, status: :opened),
      create(:event, consultation: consultation, status: :opened)
    ]

    events.map do |event|
      event.consultation.opened!

      question = create(:question, consultation: event.consultation, status: :opened)
      create(:events_question, event: event, question: question, consultation: event.consultation, status: :opened)

      question
    end

    assert subject.present?
    assert_equal consultation.id, Question.find(subject).consultation.id
  end

  private

  def init_questions(status, event)
    question = create(:question, consultation: consultation, status: status)
    event_status = status == :draft ? :closed : status

    create(:events_question, consultation: consultation, question: question, event: event, status: event_status)

    question
  end
end
