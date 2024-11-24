# frozen_string_literal: true

class DiagnosticsController < ApplicationController
  def index
    authorize :diagnostics

    @errors = errors
    @failed_deliveries = failed_deliveries
  end

  private

  def errors
    SentryApi.issues('asembleo', statsPeriod: '14d', query: 'is:unresolved')
  end

  def failed_deliveries
    access_key, secret_key = ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY']
    return :no_credentials unless access_key && secret_key

    ses_client = Aws::SESV2::Client.new(
      region: 'eu-west-1',
      credentials: Aws::Credentials.new(access_key, secret_key)
    )
    response = ses_client.list_suppressed_destinations
    response.suppressed_destination_summaries[0..50]
  end
end
