# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
  end

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
    if token.admin? || token.manager? || next_question.blank?
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
    @token ||= Token.from_hash(fingerprint)
  end

  def fingerprint
    params.require(:token)
  end
end
