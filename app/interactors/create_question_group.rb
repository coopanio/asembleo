# frozen_string_literal: true

class CreateQuestionGroup < Actor
  input :question_ids, type: Array, allow_nil: false
  input :limits, type: Array, default: -> { [] }

  output :question_group

  def call
    self.question_group = QuestionGroup.new(config: { limits: limits })

    question_group.transaction do
      question_group.save!

      question_ids.each do |question_id|
        question_group.question_links.create!(question_id: question_id)
      end
    end
  end
end
