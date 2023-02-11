# frozen_string_literal: true

require 'test_helper'

class FingerprintServiceTest < ActiveSupport::TestCase
  attr_reader :token, :receipt, :short

  setup do
    Timecop.freeze(Time.utc(2020, 9, 11, 0, 0)) do
      @consultation = create(:consultation, id: 1)
      @token = create(:token, id: 1, consultation: @consultation, salt: 9999)
      @receipt = create(:receipt, id: nil, token:)
    end
  end

  subject { FingerprintService.generate(receipt, token.to_hash, 'yes', short: @short) }

  test 'generate' do
    @short = false
    assert_equal 'ee2776265517a07d1f60b55695c2514f6852509f3190fb8014c4714ae3fddca9', subject
  end

  test 'generate short' do
    @short = true
    assert_equal 'ee2776265517a07d1f60', subject
  end
end
