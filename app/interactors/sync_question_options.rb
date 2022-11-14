# frozen_string_literal: true

class SyncQuestionOptions < Actor
  input :question, type: Question, allow_nil: false

  def call
    options = question.options

    group.questions.where.not(id: question.id).each do |q|
      q.options.delete_all
      options.each do |option|
        q.options.create!(option.attributes.except('id'))
      end
    end
  end
  
  private

  def group
    @group ||= question.group
  end
end
