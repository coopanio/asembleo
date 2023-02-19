# frozen_string_literal: true

require 'redcarpet/render_strip'

class MarkdownService < Redcarpet::Render::HTML
  OPTIONS = {
    filter_html: true,
    no_images: true,
    no_styles: true
  }.freeze

  def self.render(text, plain_text: false)
    if plain_text
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    else
      markdown = Redcarpet::Markdown.new(self, **OPTIONS)
    end

    markdown.render(text).html_safe
  end
end
