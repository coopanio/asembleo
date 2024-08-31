# frozen_string_literal: true

require 'test_helper'

class FingerprintServiceTest < ActiveSupport::TestCase
  attr_reader :token, :receipt, :short

  setup do
    Timecop.freeze(Time.utc(2020, 9, 11, 0, 0)) do
      @consultation = create(:consultation, id: 1)
      @token = create(:token, id: 1, consultation: @consultation, salt: 9999)
      @receipt = create(:receipt, id: nil, voter: @token)
    end
  end

  subject { FingerprintService.generate(receipt, token.to_hash, 'yes', short: @short) }

  test 'generate' do
    @short = false

    assert_equal 'a85da3dfccd8d6081182413747117004f01df0702dac1602d4f904c41bb882e7', subject
  end

  test 'generate short' do
    @short = true

    assert_equal 'a85da3dfccd8d6081182', subject
  end
end
