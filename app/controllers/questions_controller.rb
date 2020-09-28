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
    redirect_to action: 'show', id: @question.id
  end

  def edit
    authorize question
  end

  def update
    authorize question
    question.save!

    redirect_to action: 'show', id: @question.id
  end

  def show
    authorize question
  end

  def destroy
    authorize question
    question.destroy!
  end

  private

  def create_params
    params.require(:question).permit({})
  end

  def question
    @question ||= policy_scope(Question).find(params[:id])
  end
end
