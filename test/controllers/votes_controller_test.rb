# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  attr_reader :question, :question_params, :token, :value

  setup do
    @question = create(:question, max_options: 2)
    create(:option, question:, value: 'yes')
    create(:option, question:, value: 'no')
    event = create(:event, consultation: question.consultation)
    @token = create(:token, event:, consultation: question.consultation)
    @value = 'yes'

    @votes = { question.id => { value: [@value] } }
    @question_params = { question_id: question.id }
    reload_params!

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
      assert_predicate receipt, :present?
      assert receipt.fingerprint.present? && receipt.fingerprint.length == 64
    end
  end

  test 'should create multiple votes' do
    selected_votes = %w[yes no]
    @params['vote'][question.id][:value] = selected_votes

    subject

    Vote.all.tap do |votes|
      assert_equal selected_votes.size, votes.length
      assert_equal selected_votes.sort, votes.map(&:value).sort
      assert(votes.map(&:event).all?(@token.event))
    end

    Receipt.find_by(token:, question:).tap do |receipt|
      assert_predicate receipt, :present?
      assert receipt.fingerprint.present? && receipt.fingerprint.length == 64
    end
  end

  test "should not create multiple votes if group's main option is selected too many times" do
    other_question = create(:question, consultation: question.consultation, max_options: 1)
    CreateQuestionGroup.call(question_ids: [question.id, other_question.id])

    [question, other_question].map(&:reload)

    question.options.find_by(value: 'yes').update!(main: true)
    question.update!(max_options: 1)

    @votes = {
      question.id => { value: [@value] },
      other_question.id => { value: [@value] }
    }
    @question_params = { group_id: question.group.id }
    reload_params!

    subject

    assert_response :redirect
  end

  test "should create multiple votes if group's main option is selected up to max" do
    other_question = create(:question, consultation: question.consultation, max_options: 1)
    CreateQuestionGroup.call(question_ids: [question.id, other_question.id], limits: [{ value: 'yes', max: 2 }])

    [question, other_question].map(&:reload)

    question.options.find_by(value: 'yes').update!(main: true)
    question.update!(max_options: 1)

    @votes = {
      question.id => { value: [@value] },
      other_question.id => { value: [@value] }
    }
    @question_params = { group_id: question.group.id }
    reload_params!

    subject

    assert_response :success
  end

  test 'should asynchronously create vote' do
    CastVotes.stub_any_instance(:async?, true) do
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
    @params['vote'] = { '999' => { value: [@value] } }
    @params['question_id'] = 999
    subject

    # Not sure about this, the redirection is caused because not enough questions where found...
    assert_response :redirect
    assert_empty Vote.all
    assert_not Receipt.exists?(token:, question:)
  end

  test 'should fail if value is not valid' do
    @params['vote'][question.id][:value] = %w[nay]
    subject

    assert_response :redirect
    assert_empty Vote.all
    assert_not Receipt.exists?(token:, question:)
  end

  test 'should fail if a second vote is attempted' do
    subject
    assert_response :success

    @value = 'no'
    reload_params!

    post votes_url, params: @params
    assert_response :redirect
  end

  private

  def reload_params!
    @params = { vote: @votes }.merge(question_params).stringify_keys
  end
end
