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
    redirect_to action: 'show', id: question.id
  end

  def edit
    authorize question
  end

  def update
    authorize question
    question.save!

    redirect_to action: 'show', id: question.id
  end

  def show
    authorize question
  end

  def open
    authorize question
    rel = EventsQuestion.find_or_create_by(event: event, question: question)
    rel.update!(status: :opened)

    redirect_to controller: 'events', action: 'edit', id: event.id
  end

  def close
    authorize question
    rel = EventsQuestion.find_by(event: event, question: question)
    rel.update!(status: :closed)

    redirect_to controller: 'events', action: 'edit', id: event.id
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

  alias :close_params :open_params
end
