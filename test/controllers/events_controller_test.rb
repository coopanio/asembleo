# frozen_string_literal: true

require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token

  setup do
    @token = create(:token, :admin)

    post sessions_url, params: { token: token.to_hash }
  end

  test 'should create event' do
    params = { event: { title: 'Test' } }

    post events_url, params: params

    event = Event.first
    assert_response :redirect
    assert_equal event.title, params[:event][:title]
    assert_equal Token.all.size, 2
  end

  test 'should update event' do
    params = { event: { title: 'Test 2' } }
    event = create(:event, consultation: token.consultation)    
    
    patch event_url(event.id), params: params

    event = Event.first
    assert_response :redirect
    assert_equal 'Test 2', event.title
  end

  test 'should delete event' do
    event = create(:event, consultation: token.consultation)
    
    delete event_url(event.id)

    assert_response :redirect
    assert_equal 0, Event.all.size
  end
end
