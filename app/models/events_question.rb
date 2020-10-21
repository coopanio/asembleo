# frozen_string_literal: true

class EventsQuestion < ApplicationRecord
  has_paper_trail

  belongs_to :event
  belongs_to :question
  belongs_to :consultation

  enum status: { opened: 1, closed: 0 }
end
