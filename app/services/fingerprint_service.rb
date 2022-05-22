# frozen_string_literal: true

require 'digest'

class FingerprintService
  def self.generate(*args, short: false)
    values = args.flat_map do |arg|
      if arg.respond_to?(:attributes)
        arg.attributes.values.compact
      elsif arg.respond_to?(:append)
        arg.sort
      else
        arg
      end
    end << Rails.application.credentials.secret_key_base

    # A single question receipt is not truncated, but the result of hashing
    # all the questions' fingerprints will be truncated to 20 bytes to use it
    # as validation identifier in the published audit.
    result = Digest::SHA256.hexdigest(values.map(&:to_s).join(':'))
    return result[0..19] if short

    result
  end
end
