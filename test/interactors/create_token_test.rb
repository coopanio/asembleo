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

    assert_equal Token.count, 1
    assert_no_enqueued_emails
  end

  test 'should deliver magic link' do
    @params.merge!(
      identifier: 'voter@example.com',
      send_magic_link: true
    )

    subject

    assert_enqueued_emails 1
    assert_equal Token.count, 1
  end
end
