# frozen_string_literal: true

namespace :asembleo do
  task compile_theme: :environment do
    theme = File.read('app/assets/stylesheets/theme.scss.erb')
    template = ERB.new(theme)

    File.write('app/assets/stylesheets/theme.sass.scss', template.result)
  end
end
