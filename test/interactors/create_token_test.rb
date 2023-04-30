# frozen_string_literal: true

require 'test_helper'

class CreateTokenTest < ActionDispatch::IntegrationTest
  attr_reader :params

  setup do
    @params = { role: :voter, event: create(:event) }
  end

  subject { CreateToken.call(params) }

  test 'should create token' do
    subject

    assert_equal 1, Token.count
    assert_equal 0, TokenReceipt.count
    assert_no_enqueued_emails
  end

  test 'should deliver magic link' do
    @params[:identifier] = 'voter@example.com'
    @params[:send_magic_link] = true

    subject

    assert_enqueued_emails 1
    assert_equal 1, Token.count
    assert_equal %w[sent], Token.first.tags.map(&:value)
    assert_equal 1, TokenReceipt.count
  end
end
