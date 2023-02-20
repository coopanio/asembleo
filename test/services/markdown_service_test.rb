# frozen_string_literal: true

require 'test_helper'

class MarkdownServiceTest < ActiveSupport::TestCase
  attr_reader :text

  setup do
    @text = '## This is a test'
  end

  test 'render' do
    rendered = MarkdownService.render(text)

    assert_equal(%(<strong>This is a test</strong>), rendered)
  end

  test 'render plain text' do
    rendered = MarkdownService.render(text, plain_text: true)

    assert_equal("This is a test\n", rendered)
  end
end