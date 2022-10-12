# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  attr_reader :question, :token, :value

  setup do
    @question = create(:question)
    create(:option, question:, value: 'yes')
    create(:option, question:, value: 'no')
    event = create(:event, consultation: question.consultation)
    @token = create(:token, event:, consultation: question.consultation)
    @value = 'yes'

    @params = { vote: { question_id: question.id, value: [@value] } }

    post sessions_url, params: { session: { identifier: token.to_hash } }
  end

  subject { post votes_url, params: @params }

  test 'should create vote' do
    subject
    assert_response :success

    Vote.all.tap do |votes|
      assert_equal 1, votes.length
      assert_equal 'yes', votes.first.value
      assert_equal @token.event, votes.first.event
    end

    Receipt.find_by(token:, question:).tap do |receipt|
      assert receipt.present?
      assert receipt.fingerprint.present? && receipt.fingerprint.length == 64
    end
  end

  test 'should create multiple votes' do
    selected_votes = %w[yes no]
    @params[:vote][:value] = selected_votes

    subject

    Vote.all.tap do |votes|
      assert_equal selected_votes.size, votes.length
      assert_equal selected_votes.sort, votes.map(&:value).sort
      assert(votes.map(&:event).all? { |e| e == @token.event })
    end

    Receipt.find_by(token:, question:).tap do |receipt|
      assert receipt.present?
      assert receipt.fingerprint.present? && receipt.fingerprint.length == 64
    end
  end

  test 'should asynchronously create vote' do
    VotesController.stub_any_instance(:async?, true) do
      subject
    end

    perform_enqueued_jobs
    assert_performed_jobs 1

    Vote.all.tap do |votes|
      assert_equal 1, votes.length
      assert_equal 'yes', votes.first.value
    end

    assert_includes response.body, Receipt.first.fingerprint
  end

  test 'should fail if question_id is unknown' do
    @params[:vote][:question_id] = nil
    subject

    assert_response 400
    assert_empty Vote.all
    assert_not Receipt.exists?(token:, question:)
  end

  test 'should fail if value is not valid' do
    @params[:vote][:value] = %w[nay]
    subject

    assert_response :redirect
    assert_empty Vote.all
    assert_not Receipt.exists?(token:, question:)
  end

  test 'should fail if a second vote is attempted' do
    subject
    assert_response :success

    post votes_url, params: { vote: { question_id: question.id, value: %w[no] } }
    assert_response :redirect
  end
end
