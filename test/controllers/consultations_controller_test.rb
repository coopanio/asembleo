# frozen_string_literal: true

require 'test_helper'

class ConsultationsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :params

  setup do
    @params = { consultation: { title: 'Test', description: 'Description' } }
  end

  test 'should create consultation' do
    post consultations_url, params: params

    consultation = Consultation.first
    assert_response :redirect
    assert_equal params[:consultation][:title], consultation.title
    assert_equal params[:consultation][:description], consultation.description
  end

  test 'should update consultation' do
    token = create(:token, :admin)
    post sessions_url, params: { token: token.to_hash }

    @params = { consultation: { status: 'opened' } }
    patch consultation_url(token.consultation.id), params: params

    consultation = Consultation.all.first
    assert_response :redirect
    assert_equal params[:consultation][:status], consultation.status
  end
end
