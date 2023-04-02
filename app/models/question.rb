# frozen_string_literal: true

class Question < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_one :link, class_name: 'QuestionLink', dependent: :destroy
  has_one :group, class_name: 'QuestionGroup', through: :link, source: :question_group, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :events_questions, dependent: :destroy

  enum status: { draft: 0, opened: 1, closed: 2 }

  after_save :sync_siblings

  def valid_option?(value)
    options.exists?(value:)
  end

  def voted?(token)
    receipts.exists?(token:)
  end

  def short_description
    return '' if description.blank?

    description.split("\n").first.strip
  end

  def position
    weight + 1
  end

  def tally
    results = {}

    votes.each do |vote|
      result = results[vote.value] || 0
      results[vote.value] = result + (vote.weight * 1)
    end

    total_votes = results.values.sum
    results['_meta'] = {
      'breakdown' => tally_by_event,
      'total_votes' => total_votes.zero? ? nil : total_votes
    }

    results
  end

  private

  def tally_by_event
    results = {}

    votes.each do |vote|
      event_results = results[vote.event_id] || {}
      result = event_results[vote.value] || 0
      event_results[vote.value] = result + (vote.weight * 1)

      results[vote.event_id] = event_results
    end

    results
  end

  def sync_siblings
    SyncQuestionSiblings.call(question: self)
  end

  private :link, :link=
end
