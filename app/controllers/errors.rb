# frozen_string_literal: true

module Errors
  def self.included(clazz)
    clazz.class_eval do
      rescue_from ActiveRecord::RecordNotFound, ActionController::BadRequest do |_e|
        render plain: I18n.t("errors.bad_request"), status: :bad_request
      end

      rescue_from TooManyOptions do |e|
        error(I18n.t("errors.you_can_only_choose_up_to", e_max_options: (e.max_options)))
        redirect_back fallback_location: root_path
      end

      rescue_from TooManyMainOptions do |e|
        error(I18n.t("errors.you_can_only_choose_up_to2", e_option_value: (e.option.value), e_limit: (e.limit)))
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidVoteOption do |_e|
        error(I18n.t("errors.choose_a_valid_option"))
        redirect_back fallback_location: root_path
      end

      rescue_from AlreadyVoted do |_e|
        error(I18n.t("errors.you_already_voted_for_this"))
        redirect_to controller: 'consultations', action: 'show', id: current_user.consultation.id
      end

      rescue_from AccessDenied do |_e|
        error(I18n.t("errors.access_denied"))

        if Rails.configuration.x.asembleo.private_instance
          redirect_to new_session_path
        else
          redirect_to root_path
        end
      end

      rescue_from Pundit::NotAuthorizedError do |_e|
        error(I18n.t("errors.not_authorized"))
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidParameters do |e|
        error(e.message)
        redirect_back fallback_location: root_path
      end
    end
  end

  class AccessDenied < ActionController::ActionControllerError; end

  class InvalidParameters < ActionController::BadRequest
    def initialize(msg = I18n.t("errors.invalid_parameters"))
      super
    end
  end

  class TooManyOptions < ActionController::BadRequest
    attr_reader :max_options

    def initialize(max_options)
      @max_options = max_options
    end
  end

  class TooManyMainOptions < ActionController::BadRequest
    attr_reader :option, :limit

    def initialize(option, limit)
      @option = option
      @limit = limit
    end
  end

  class InvalidVoteOption < ActionController::BadRequest; end

  class AlreadyVoted < ActionController::BadRequest; end

  class InvalidEmail < ActionController::BadRequest; end
end
