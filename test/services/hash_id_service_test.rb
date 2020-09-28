# frozen_string_literal: true

class HashIdServiceTest < ActiveSupport::TestCase
  attr_reader :ids, :value

  setup do
    @ids = [1, 5]
    @value = '97ekhz74'
  end

  test 'encode' do
    encoded = HashIdService.encode(*ids)
    assert_equal(value, encoded)
  end

  test 'decode' do
    decoded = HashIdService.decode(value)
    assert_equal(ids, decoded)
  end

  test 'that handles nil values' do
    @ids = [1, nil, 5]
    @value = '7ekhkta7'
    encoded = HashIdService.encode(*ids)
    decoded = HashIdService.decode(encoded)
    assert_equal(value, encoded)
    assert_equal(ids.map { |id| id.nil? ? 0 : id }, decoded)
  end
end
