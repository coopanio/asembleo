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
    assert_equal '050893424e6e39c6cecf0ae010185be7af5e971b5ccc2235c68d96218a5a38cd', subject
  end

  test 'generate short' do
    @short = true
    assert_equal '050893424e6e39c6cecf', subject
  end
end
