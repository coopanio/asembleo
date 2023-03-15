# frozen_string_literal: true

require 'test_helper'

class RedirectBySessionTest < ActiveSupport::TestCase
  attr_reader :consultation, :identity

  setup do
    @consultation = create(:consultation)
    @identity = create(:token, consultation:)

    Context.reset
    Context.identity = identity
    Context.consultation_id = consultation.id
  end

  subject { RedirectBySession.call(Context.to_h).destination }

  test 'should return the consultation' do
    assert_equal subject, "/consultations/#{consultation.id}"
  end

  test 'should return the consultation (all in draft status)' do
    create(:question, consultation:)

    assert_equal subject, "/consultations/#{consultation.id}"
  end

  test 'should return the first open question' do
    question = create(:question, consultation:, status: :opened)
    create(:events_question, question:, consultation:, status: :opened)

    assert_predicate subject, :present?
    assert_equal subject, "/consultations/#{consultation.id}/questions/#{question.id}"
  end

  test 'should return the first open question (second)' do
    event = create(:event)

    questions = %i[closed opened draft].map do |status|
      init_questions(status, event)
    end

    assert_predicate subject, :present?
    assert_equal subject, "/consultations/#{consultation.id}/questions/#{questions.second.id}"
  end

  test 'should return the first un-voted and open question (third)' do
    event = create(:event)
    questions = %i[closed opened opened draft].map do |status|
      init_questions(status, event)
    end

    create(:receipt, token: identity, question: questions.first)
    create(:receipt, token: identity, question: questions.second)

    assert_predicate subject, :present?
    assert_equal subject, "/consultations/#{consultation.id}/questions/#{questions.third.id}"
  end

  test 'should return the first open question when multiple consultations are active' do
    events = [
      create(:event, status: :opened),
      create(:event, consultation:, status: :opened)
    ]

    events.map do |event|
      event.consultation.opened!

      question = create(:question, consultation: event.consultation, status: :opened)
      create(:events_question, event:, question:, consultation: event.consultation, status: :opened)

      question
    end

    assert_predicate subject, :present?
    assert_equal subject, "/consultations/#{consultation.id}/questions/#{events.second.consultation.questions.first.id}"
  end

  test 'should return the front page when user is an instance user' do
    @identity = create(:user)

    Context.reset
    Context.identity = identity

    assert_predicate subject, :present?
    assert_equal '/consultations', subject
  end

  test 'should return the consultation page when user is an instance user and the consultation is known' do
    @identity = create(:user)

    Context.reset
    Context.identity = identity
    Context.consultation_id = consultation.id

    assert_predicate subject, :present?
    assert_equal "/consultations/#{consultation.id}", subject
  end

  private

  def init_questions(status, event)
    question = create(:question, consultation:, status:)
    event_status = status == :draft ? :closed : status

    create(:events_question, consultation:, question:, event:, status: event_status)

    question
  end
end
