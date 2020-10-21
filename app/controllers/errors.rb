# frozen_string_literal: true

module Errors
  def self.included(clazz)
    clazz.class_eval do
      rescue_from ActiveRecord::RecordNotFound, ActionController::BadRequest do |_e|
        render plain: 'Bad request', status: :bad_request
      end

      rescue_from InvalidVoteOption do |_e|
        error('Choose a valid option.')
        redirect_back fallback_location: root_path
      end

      rescue_from AlreadyVoted do |_e|
        error('You already voted for this question.')
        redirect_to controller: 'consultations', action: 'show', id: consultation.id
      end

      rescue_from AccessDenied do |_e|
        error('Access denied.')
        redirect_to root_path
      end

      rescue_from Pundit::NotAuthorizedError do |_e|
        error('You are not authorized.')
        redirect_back fallback_location: root_path
      end
    end
  end

  class AccessDenied < ActionController::ActionControllerError; end

  class InvalidVoteOption < ActionController::BadRequest; end

  class AlreadyVoted < ActionController::BadRequest; end
end
