# frozen_string_literal: true

class ImportQuestions < Actor
  input :content, type: String
  input :consultation, type: Consultation

  output :questions, type: Array

  def call
    validate
    import
  end

  private

  def validate
    renderer = QuestionRender.new
    parser = Redcarpet::Markdown.new(renderer)
    parser.render(content)

    self.questions = renderer.questions
    fail!(errors: 'No questions found') if questions.empty?

    invalid_questions = renderer.invalid_questions
    fail!(errors: "No answers found in #{invalid_questions.map { |q| q[:title] }.join(', ')}") unless invalid_questions.empty?
  end

  def import
    Question.transaction do
      questions.each do |q|
        description = "## #{q[:title]}\n\n#{q[:description]}".strip
        question = Question.create!(description:, consultation:)
        q[:answers].each do |description|
          value = description
          Option.create!(question:, description:, value:)
        end
      end
    end
  end

  class QuestionRender < Redcarpet::Render::Base
    def initialize
      super
      @questions = []
    end

    def header(title, level)
      title.strip!
      @questions << {title:} if level == 2
      nil
    end

    def paragraph(text)
      return if @questions.empty?

      @questions.last[:description] ||= ''.dup
      @questions.last[:description] << text.strip << "\n\n"
      nil
    end

    def list_item(content, list_type)
      return if @questions.empty?

      @questions.last[:answers] ||= []
      @questions.last[:answers] << content.strip
      nil
    end

    def questions
      @questions
    end

    def invalid_questions
      @questions.select { |q| q[:answers].nil? || q[:answers].empty? }
    end
  end
end
