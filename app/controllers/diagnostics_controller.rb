# frozen_string_literal: true

class DiagnosticsController < ApplicationController
  def index
    authorize :diagnostics

    @errors = SentryApi.issues('asembleo', statsPeriod: '14d', query: 'is:unresolved')
  end
end
