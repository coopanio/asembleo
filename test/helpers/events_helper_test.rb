# frozen_string_literal: true

require 'test_helper'

class EventsHelperTest < ActionView::TestCase
  attr_accessor :event, :question, :expected

  setup do
    consultation = create(:consultation, status: :opened)
    @event = create(:event, consultation: consultation)
    @question = create(:question, consultation: consultation, status: :opened)

    @expected = {
      open: "<form class=\"button_to\" method=\"post\" action=\"/questions/#{question.id}/open?event%5Bid%5D=#{event.id}\"><input type=\"hidden\" name=\"_method\" value=\"patch\" /><input class=\"btn btn-link py-0\" type=\"submit\" value=\"Obrir\" /></form>",
      close: "<form class=\"button_to\" method=\"post\" action=\"/questions/#{question.id}/close?event%5Bid%5D=#{event.id}\"><input type=\"hidden\" name=\"_method\" value=\"patch\" /><input class=\"btn btn-link py-0\" type=\"submit\" value=\"Tancar\" /></form>"
    }
  end

  subject { question_opener_closer_link(event, question) }

  test 'return open link when no record is found' do
    assert_equal expected[:open], subject
  end

  test 'return open link' do
    create(:events_question, event: event, question: question)
    assert_equal expected[:open], subject
  end

  test 'return close link' do
    create(:events_question, event: event, question: question, status: :opened)
    assert_equal expected[:close], subject
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
