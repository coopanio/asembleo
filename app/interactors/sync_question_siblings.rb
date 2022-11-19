# frozen_string_literal: true

class SyncQuestionSiblings < Actor
  input :question, type: Question, allow_nil: false

  def call
    return if group.blank?

    QuestionGroup.transaction do
      questions.each do |q|
        update_status(q)
        update_options(q)
      end
    end
  end

  private

  def update_status(target)
    EventsQuestion.where(event: events, question: target).update_all(status: question.status)
    target.update_columns(status: question.status)
  end

  def update_options(target)
    target.options.delete_all

    options.each do |option|
      target.options.create!(option.attributes.except('id'))
    end
  end

  def group
    @group ||= question.group
  end

  def questions
    @questions ||= group.questions.where.not(id: question.id)
  end

  def options
    question.options
  end

  def events
    @events ||= question.consultation.events
  end
end
