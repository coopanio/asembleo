# frozen_string_literal: true

require 'test_helper'

class FingerprintServiceTest < ActiveSupport::TestCase
  attr_reader :token, :receipt, :short

  setup do
    Timecop.freeze(Time.utc(2020, 9, 11, 0, 0)) do
      @token = create(:token)
      @receipt = create(:receipt, id: nil, token: token)
    end
  end

  subject { FingerprintService.generate(receipt, token.to_hash, 'yes', short: @short) }

  test 'generate' do
    @short = false
    assert_equal '6346d0bf6b209235dd67e7742a4f65728379e038676edd7c6459134933269d2b', subject
  end

  test 'generate short' do
    @short = true
    assert_equal '6346d0bf6b209235dd67', subject
  end
end
