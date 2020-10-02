# frozen_string_literal: true

class QuestionsController < ApplicationController
  def new
    authorize Question
    @question = Question.new(consultation: current_user.consultation)
  end

  def create
    @question = Question.new(create_params)
    authorize @question

    @question.save!
    redirect_to action: 'edit', id: question.id
  end

  def edit
    authorize question
  end

  def update
    authorize question
    question.save!

    redirect_back(fallback_location: root_path)
  end

  def show
    authorize question
  end

  def open
    authorize question

    EventsQuestion.transaction do
      rel = EventsQuestion.find_or_create_by(event: event, question: question)
      rel.update!(status: :opened)

      question.update!(status: :opened) if consultation.config.synchronous?
    end

    redirect_back(fallback_location: root_path)
  end

  def tally
    authorize question

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

      question.update!(status: :closed) if consultation.config.synchronous?
    end

    redirect_back(fallback_location: root_path)
  end

  def destroy
    authorize question
    question.destroy!
  end

  private

  def question
    @question ||= policy_scope(Question).find(params[:id])
  end

  def event
    @event ||= policy_scope(Event).find(open_params[:id])
  end

  def create_params
    params.require(:question).permit({})
  end

  def open_params
    params.require(:event).permit(:id)
  end

  alias close_params open_params
end
