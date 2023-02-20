# frozen_string_literal: true

require 'redcarpet/render_strip'

class MarkdownService < Redcarpet::Render::HTML
  OPTIONS = {
    filter_html: true,
    no_images: true,
    no_styles: true
  }.freeze

  def self.render(text, plain_text: false)
    markdown = if plain_text
                 Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
               else
                 Redcarpet::Markdown.new(self, **OPTIONS)
               end

    content = markdown.render(text)
    ActionController::Base.helpers.sanitize(content)
  end

  def header(text, _header_level)
    %(<strong>#{text}</strong>)
  end
end
