# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    reset_session
    session[:token] = token.id

    redirect_to destination
  rescue Hashids::InputError, ActiveRecord::RecordNotFound
    raise Errors::AccessDenied
  end

  def destroy
    reset_session
    redirect_to controller: 'main', action: 'index'
  end

  private

  def destination
    if token.admin?
      edit_consultation_url(consultation)
    elsif token.manager?
      edit_event_url(token.event)
    elsif next_question.blank?
      consultation_url(consultation)
    else
      question_url(next_question)
    end
  end

  def next_question
    @next_question ||= consultation.questions.next(token)
  end

  def consultation
    @consultation ||= token.consultation
  end

  def token
    return @token if defined?(@token)

    @token = Token.from_hash(identifier)
    @token = Token.from_alias(identifier) if @token.nil?

    @token
  end

  def identifier
    params.require(:token)
  end
end
