# frozen_string_literal: true

namespace :asembleo do
  task :compile_theme => :environment do
    theme = File.open('app/assets/stylesheets/theme.sass.erb').read
    template = ERB.new(theme)

    css = Sass::Engine.new(template.result, syntax: :scss, load_paths: ['node_modules/']).render
    File.open('app/assets/stylesheets/theme.sass.scss', 'w') { |f| f.write(css) }
  end
end
