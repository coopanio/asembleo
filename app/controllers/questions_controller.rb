# frozen_string_literal: true

class QuestionsController < ApplicationController
  def new
    authorize Question
    @question = Question.new(consultation: consultation)
  end

  def create
    authorize Question

    @question = Question.new(create_params.merge(consultation: consultation))
    @question.save!

    success('Question created.')
    redirect_to action: 'edit', id: @question.id
  end

  def edit
    authorize question
  end

  def update
    authorize question
    question.update!(update_params)

    success('Question updated.')
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  def show
    authorize question

    raise Errors::AlreadyVoted if question.voted?(current_user)
  end

  def new_option
    authorize question, :edit?
  end

  def open
    authorize question

    EventsQuestion.transaction do
      rel = EventsQuestion.find_or_create_by(event: event, question: question, consultation: consultation)
      rel.update!(status: :opened)

      question.update!(status: :opened) if consultation.synchronous?
    end

    success('Question opened.')
    redirect_back(fallback_location: root_path)
  end

  def tally
    authorize question
    unless question.closed?
      error('Results not available while the question is open.')
      redirect_to controller: 'consultations', action: 'edit', id: consultation.id
      return
    end

    @consultation = question.consultation
    @results = question.tally
  end

  def close
    authorize question

    EventsQuestion.transaction do
      rel = EventsQuestion.find_by(event: event, question: question)
      rel.update!(status: :closed)

      question.update!(status: :closed) if consultation.synchronous?
    end

    success('Question closed.')
    redirect_back(fallback_location: root_path)
  end

  def destroy
    authorize question
    question.destroy!

    success('Question deleted.')
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  private

  def consultation
    current_user.consultation
  end

  def question
    @question ||= Rails.cache.fetch("questions:#{params[:id]}") do
      policy_scope(Question).find(params[:id])
    end
  end

  def event
    @event ||= policy_scope(Event).find(open_params[:id])
  end

  def create_params
    params.require(:question).permit(:description)
  end

  def update_params
    params.require(:question).permit(:description, :status)
  end

  def open_params
    params.require(:event).permit(:id)
  end

  alias close_params open_params
end
