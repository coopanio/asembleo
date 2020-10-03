# frozen_string_literal: true

class OptionsController < ApplicationController
  def new
    authorize question
    authorize Option

    @option = Option.new(question: question)
  end

  def create
    authorize question

    @option = Option.new(create_params.merge(question: question))
    authorize option

    option.save!

    success('Opció creada.')
    redirect_to controller: 'questions', action: 'edit', id: question.id
  end

  def edit
    authorize question
    authorize option
  end

  def update
    authorize question
    authorize option

    option.update!(update_params)

    success('Opció actualizada.')
    redirect_to controller: 'questions', action: 'edit', id: question.id
  end

  def destroy
    authorize question
    authorize option

    option.destroy!

    success('Opció eliminada.')
    redirect_to controller: 'questions', action: 'edit', id: question.id
  end

  private

  def question
    @question ||= Question.find(params[:question_id])
  end

  def option
    @option ||= Option.find(params[:id])
  end

  def create_params
    params.require(:option).permit(:value, :description)
  end

  alias update_params create_params
end
