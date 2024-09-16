# frozen_string_literal: true

require 'test_helper'

class MarkdownRenderServiceTest < ActiveSupport::TestCase
  attr_reader :text

  setup do
    @text = '## This is a test'
  end

  test 'render' do
    rendered = MarkdownRenderService.render(text)

    assert_equal(%(<h4>This is a test</h4>), rendered)
  end

  test 'render plain text' do
    rendered = MarkdownRenderService.render(text, plain_text: true)

    assert_equal("This is a test\n", rendered)
  end
end