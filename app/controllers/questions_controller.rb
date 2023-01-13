# frozen_string_literal: true

class QuestionsController < ApplicationController
  def new
    authorize Question
    @question = Question.new(consultation:)
  end

  def create
    authorize Question

    @question = Question.new(create_params.merge(consultation:))
    @question.save!

    success('Question created.')
    redirect_to action: 'edit', id: @question.id
  end

  def edit
    @consultation = consultation
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

    update_status(:opened)

    success('Question opened.')
    redirect_back(fallback_location: root_path)
  end

  def open_all
    authorize question, :open?

    update_status(:opened, events: question.consultation.events)

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

    @consultation = consultation
    @results = question.tally
  end

  def close
    authorize question

    update_status(:closed)

    success('Question closed.')
    redirect_back(fallback_location: root_path)
  end

  def close_all
    authorize question, :close?

    update_status(:closed, events: question.consultation.events)

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

  def update_status(status, events: [event])
    EventsQuestion.transaction do
      events.each do |event|
        rel = EventsQuestion.find_or_create_by(consultation:, question:, event:)
        rel.update!(status:)

        question.update!(status:) if consultation.synchronous?
      end
    end
  end

  def consultation
    @consultation = Consultation.find(params[:consultation_id])
  end

  def question
    @question ||= Question.find(params[:id])
  end

  def event
    @event ||= Event.find(open_params[:id])
  end

  def create_params
    params.require(:question).permit(:description, :max_options)
  end

  def update_params
    params.require(:question).permit(:description, :status, :max_options)
  end

  def open_params
    params.require(:event).permit(:id)
  end

  alias close_params open_params
end
