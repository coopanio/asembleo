# frozen_string_literal: true

require 'csv'

namespace :assemblea do
  task :send_tokens, [:filename, :consultation_id] => :environment do |t, args|
    p args
    consultation = Consultation.find(args[:consultation_id])
    csv_file = File.open(args[:filename])
    csv = CSV.new(csv_file)
    csv.each do |row|
      to = row[0]

      token = Token.new(consultation: consultation, event: consultation.events.first)
      
      token.save!
      token.reload
      
      puts "#{to} => #{token.to_hash}"
      SessionsMailer.magic_link_email(to, token).deliver_now
    end
  end
end
