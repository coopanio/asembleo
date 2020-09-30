# frozen_string_literal: true

require 'test_helper'

class EventsHelperTest < ActionView::TestCase
  attr_accessor :event, :question

  setup do
    consultation = create(:consultation, status: :opened)
    @event = create(:event, consultation: consultation)
    @question = create(:question, consultation: consultation, status: :opened)
  end

  subject { question_opener_closer_link(event, question) }

  test 'return open link when no record is found' do
    assert_equal "<a href=\"/questions/#{question.id}/open?method=patch\">Obrir</a>", subject
  end

  test 'return open link' do
    create(:events_question, event: event, question: question)
    assert_equal "<a href=\"/questions/#{question.id}/open?method=patch\">Obrir</a>", subject
  end

  test 'return close link' do
    create(:events_question, event: event, question: question, status: :opened)
    assert_equal "<a href=\"/questions/#{question.id}/close?method=patch\">Tancar</a>", subject
  end

  test 'return no link when question is not opened' do
    question.update!(status: :draft)
    assert_equal '-', subject
  end

  test 'return no link when consultation is not open' do
    question.consultation.update!(status: :draft)
    assert_equal '-', subject
  end
end
