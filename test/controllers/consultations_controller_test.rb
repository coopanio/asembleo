# frozen_string_literal: true

require 'test_helper'

class ConsultationsControllerTest < ControllerTestCase
  attr_reader :params, :token

  setup do
    @params = { consultation: { title: 'Test', description: 'Description' } }
    @token = create_admin_token
    event = create(:event, consultation: @token.consultation)
    @token.update!(event:)
  end

  test 'should create consultation' do
    post(consultations_url, params:)

    consultation = Consultation.last

    assert_response :redirect
    assert_predicate session[:identity_id], :present?
    assert_not_equal token.id, session[:identity_id]
    assert Token.exists?(role: :manager, consultation:)
    assert_equal 1, Event.where(consultation:).count
    assert_equal params[:consultation][:title], consultation.title
    assert_equal params[:consultation][:description], consultation.description
  end

  test 'should create consultation with admin user' do
    @token = create_admin_user
    login_user

    assert_emails 1 do
      post(consultations_url, params:)
    end

    consultation = Consultation.last

    assert_response :redirect
    assert_equal params[:consultation][:title], consultation.title
    assert_equal params[:consultation][:description], consultation.description
  end

  test 'should redirect on list consultations if not identified' do
    get consultations_url

    assert_response :redirect
  end

  test 'should edit consultation' do
    login_token

    get edit_consultation_url(token.consultation.id)

    assert_response :success
  end

  test 'should update consultation' do
    login_token

    @params = { consultation: { status: 'opened' } }
    patch(consultation_url(token.consultation.id), params:)

    consultation = Consultation.all.first

    assert_response :redirect
    assert_equal params[:consultation][:status], consultation.status
  end
end
