# frozen_string_literal: true

namespace :asembleo do
  task compile_theme: :environment do
    theme = File.read('app/assets/stylesheets/theme.sass.erb')
    template = ERB.new(theme)

    css = Sass::Engine.new(template.result, syntax: :scss, load_paths: ['node_modules/']).render
    File.write('app/assets/stylesheets/theme.sass.scss', css)
  end
end
