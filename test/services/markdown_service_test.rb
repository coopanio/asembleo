# frozen_string_literal: true

require 'test_helper'

class MarkdownServiceTest < ActiveSupport::TestCase
  attr_reader :text

  setup do
    @text = '## This is a test'
  end

  test 'render' do
    rendered = MarkdownService.render(text)

    assert_equal(%(<h4>This is a test</h4>), rendered)
  end

  test 'render plain text' do
    rendered = MarkdownService.render(text, plain_text: true)

    assert_equal("This is a test\n", rendered)
  end
end