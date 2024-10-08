# frozen_string_literal: true

module Errors
  def self.included(clazz)
    clazz.class_eval do
      rescue_from ActiveRecord::RecordNotFound, ActionController::BadRequest do |_e|
        render plain: I18n.t('errors.bad_request'), status: :bad_request
      end

      rescue_from TooManyOptions do |e|
        error(I18n.t('errors.you_can_only_choose_up_to', e_max_options: e.max_options))
        redirect_back fallback_location: root_path
      end

      rescue_from TooManyMainOptions do |e|
        error(I18n.t('errors.you_can_only_choose_up_to2', e_option_value: e.option.value, e_limit: e.limit))
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidVoteOption do |_e|
        error(I18n.t('errors.choose_a_valid_option'))
        redirect_back fallback_location: root_path
      end

      rescue_from AlreadyVoted do |e|
        error(I18n.t('errors.you_already_voted_for_this'))
        redirect_to controller: 'consultations', action: 'show', id: e.consultation.id
      end

      rescue_from AccessDenied do |e|
        error(I18n.t('errors.access_denied'))

        if e.identifier_type == :user
          redirect_to new_session_path
        else
          redirect_to root_path
        end
      end

      rescue_from Pundit::NotAuthorizedError do |_e|
        error(I18n.t('errors.not_authorized'))
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidEmail do |e|
        error(e.message)
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidIdentity do |e|
        error(e.message)
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidParameters do |e|
        error(e.message)
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidIdentifiers do |e|
        identifiers = e.invalid_identifiers.map { |identifier| identifier.inspect }

        error("#{e.message} (#{identifiers.join(', ')})")
        redirect_back fallback_location: root_path
      end

      rescue_from InvalidTokenScope do |_e|
        error(I18n.t('errors.invalid_token_scope'))
        redirect_back fallback_location: root_path
      end

      rescue_from ClosedConsultation do |_e|
        error(I18n.t('events.token_consultation_closed'))
        redirect_back fallback_location: root_path
      end

      rescue_from ActionController::InvalidAuthenticityToken do |_e|
        error(I18n.t('errors.access_denied'))
        redirect_back fallback_location: root_path
      end
    end
  end

  class AccessDenied < ActionController::ActionControllerError
    attr_reader :identifier_type

    def initialize(msg = I18n.t('errors.access_denied'), identifier_type: Token.name.underscore.to_sym)
      @identifier_type = identifier_type

      super(msg)
    end
  end

  class InvalidEmail < ActionController::BadRequest
    def initialize(msg = I18n.t('errors.invalid_email'))
      super
    end
  end

  class InvalidIdentity < ActionController::BadRequest
    def initialize(msg = I18n.t('errors.invalid_identity'))
      super
    end
  end

  class InvalidParameters < ActionController::BadRequest
    def initialize(msg = I18n.t('errors.invalid_parameters'))
      super
    end
  end

  class TooManyOptions < ActionController::BadRequest
    attr_reader :max_options

    def initialize(max_options)
      super(nil)

      @max_options = max_options
    end
  end

  class TooManyMainOptions < ActionController::BadRequest
    attr_reader :option, :limit

    def initialize(option, limit)
      super(nil)

      @option = option
      @limit = limit
    end
  end

  class InvalidVoteOption < ActionController::BadRequest; end

  class AlreadyVoted < ActionController::BadRequest
    attr_reader :consultation

    def initialize(msg = I18n.t('errors.you_already_voted_for_this'), consultation: nil)
      super(msg)

      @consultation = consultation
    end
  end

  class InvalidIdentifiers < ActionController::BadRequest
    attr_reader :invalid_identifiers

    def initialize(msg = I18n.t('errors.invalid_identifiers'), invalid_identifiers:)
      super(msg)

      @invalid_identifiers = invalid_identifiers
    end
  end

  class InvalidTokenScope < ActionController::BadRequest; end

  class ClosedConsultation < ActionController::BadRequest; end
end
