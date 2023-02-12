# frozen_string_literal: true

class QuestionGroupsController < ApplicationController
  def index
    authorize QuestionGroup

    @groups = policy_scope(QuestionGroup).all
    @available_questions = policy_scope(Question).joins('LEFT JOIN question_links ON questions.id = question_links.question_id').where(question_links: { question_group_id: nil })
  end

  def create
    authorize QuestionGroup
    raise Errors::InvalidParameters, I18n.t('question_groups.required_questions') unless params[:question_group].present?

    question_ids = create_params[:question_ids]
    raise Errors::InvalidParameters, I18n.t('question_groups.required_questions') if question_ids.empty? || question_ids.size < 2

    question_ids = question_ids.map(&:to_i)
    QuestionGroup.transaction do
      CreateQuestionGroup.call(question_ids: question_ids)
      SyncQuestionSiblings.call(question: Question.find(question_ids.first))
    end

    redirect_to consultation_question_groups_path
  end

  def edit
    @consultation = Consultation.find(params[:consultation_id])
    @question_group = QuestionGroup.find(params[:id])
    authorize @question_group
  end

  def update
    question_group = QuestionGroup.find(params[:id])
    authorize question_group

    question_group.update!(update_params)
    redirect_to consultation_question_groups_path
  end

  def destroy
    group = QuestionGroup.find(params[:id])
    authorize group

    group.destroy!
    redirect_to consultation_question_groups_path
  end

  private

  def create_params
    params.require(:question_group).permit(question_ids: [])
  end

  def update_params
    params.require(:question_group).permit(:description)
  end

  def consultation
    @consultation ||= Consultation.find(params[:consultation_id])
  end
end
