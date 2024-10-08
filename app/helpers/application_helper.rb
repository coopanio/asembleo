# frozen_string_literal: true

module ApplicationHelper
  def markdown(text, plain_text: false)
    MarkdownRenderService.render(text, plain_text:)
  end
end
