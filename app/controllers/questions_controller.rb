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

    success(I18n.t('questions.question_created'))
    redirect_to action: 'edit', id: @question.id
  end

  def edit
    @consultation = consultation
    authorize question
  end

  def update
    authorize question

    question.update!(update_params)

    success(I18n.t('questions.question_updated'))
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  def show
    authorize question

    raise Errors::AlreadyVoted.new(consultation: question.consultation) if question.voted?(current_user)
  end

  def new_option
    authorize question, :edit?
  end

  def open
    authorize question

    update_status(:opened)

    success(I18n.t('questions.question_opened'))
    redirect_back(fallback_location: root_path)
  end

  def open_all
    authorize question, :open?

    update_status(:opened, events: question.consultation.events)

    success(I18n.t('questions.question_opened'))
    redirect_back(fallback_location: root_path)
  end

  def tally
    authorize question

    unless question.closed?
      error(I18n.t('questions.results_not_available'))
      redirect_to controller: 'consultations', action: 'edit', id: consultation.id
      return
    end

    @consultation = consultation
    @results = question.tally
    @results['_meta']['graph'] = question.options.map do |option|
      [
        option.description,
        @results[option.value]
      ]
    end
  end

  def close
    authorize question

    update_status(:closed)

    success(I18n.t('questions.question_closed'))
    redirect_back(fallback_location: root_path)
  end

  def close_all
    authorize question, :close?

    update_status(:closed, events: question.consultation.events)

    success(I18n.t('questions.question_closed'))
    redirect_back(fallback_location: root_path)
  end

  def destroy
    authorize question
    question.destroy!

    success(I18n.t('questions.question_deleted'))
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  def import
    authorize consultation, :edit?

    if request.post?
      content = if params[:value].present?
        params[:value].open.read
      elsif params[:value_raw].present?
        params[:value_raw]
      else
        error(I18n.t('errors.bad_request'))
        redirect_back(fallback_location: root_path)
        return
      end

      result = ImportQuestions.result(consultation:, content:)
      raise result.error if result.failure?

      success(I18n.t('questions.imported'))
      redirect_to controller: 'consultations', action: 'edit', id: consultation.id
    end
  end

  private

  def update_status(status, events: [question_event])
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

  def question_event
    @question_event ||= Event.find(open_params[:id])
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
