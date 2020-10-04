# frozen_string_literal: true

class QuestionsController < ApplicationController
  def new
    authorize Question
    @question = Question.new(consultation: current_user.consultation)
  end

  def create
    @question = Question.new(create_params.merge(consultation: consultation))
    authorize @question

    @question.save!

    success('Pregunta creada.')
    redirect_to action: 'edit', id: question.id
  end

  def edit
    authorize question
  end

  def update
    authorize question
    question.update!(update_params)

    success('Pregunta actualizada.')
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
      rel = EventsQuestion.find_or_create_by(event: event, question: question)
      rel.update!(status: :opened)

      question.update!(status: :opened) if consultation.synchronous?
    end

    success('Pregunta oberta.')
    redirect_back(fallback_location: root_path)
  end

  def tally
    authorize question
    unless question.closed?
      error('Els resultats no es poden veure mentre la pregunta és oberta.')
      redirect_to controller: 'consultations', action: 'edit', id: consultation.id
      return
    end

    @results = {}
    Vote.where(question: question).each do |vote|
      result = @results[vote.value] || 0
      @results[vote.value] = result + 1
    end
  end

  def close
    authorize question

    EventsQuestion.transaction do
      rel = EventsQuestion.find_by(event: event, question: question)
      rel.update!(status: :closed)

      question.update!(status: :closed) if consultation.synchronous?
    end

    success('Pregunta tancada.')
    redirect_back(fallback_location: root_path)
  end

  def destroy
    authorize question
    question.destroy!

    success('Pregunta eliminada.')
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  private

  def consultation
    current_user.consultation
  end

  def question
    @question ||= policy_scope(Question).find(params[:id])
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
