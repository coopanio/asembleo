# frozen_string_literal: true

module Errors
  def self.included(clazz)
    clazz.class_eval do
      rescue_from ActiveRecord::RecordNotFound, ActionController::BadRequest do |_e|
        # TODO: i18n
        # TODO unify rendering
        render plain: 'Bad request', status: :bad_request
      end

      rescue_from AccessDenied, Pundit::NotAuthorizedError do |_e|
        render plain: 'Unauthorized', status: :unauthorized
      end
    end
  end

  class AccessDenied < ActionController::ActionControllerError; end

  class InvalidVoteOption < ActionController::BadRequest; end

  class AlreadyVoted < ActionController::BadRequest; end
end
