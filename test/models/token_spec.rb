# frozen_string_literal: true

require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  test 'sanitize tokens' do
    cases = [
      { value: 'dcc2309', expected: 'dcc2309' },
      { value: '+34 099 999 999', expected: '34099999999' },
      { value: ' ohai_thxby ', expected: 'ohaithxby' },
      { value: '69a 334 x 13.ç', expected: '69a334x13' },
    ]
    cases.each do |c|
      assert_equal c[:expected], Token.sanitize(c[:value])
    end
  end
  
  test 'should not create tokens with equal aliases' do
    create(:token, alias: 'test')
    assert_raises ActiveRecord::RecordInvalid do
      create(:token, alias: 'test')
    end
  end
end
