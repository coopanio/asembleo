# frozen_string_literal: true

class EventsQuestion < ApplicationRecord
  belongs_to :event
  belongs_to :question

  enum status: { opened: 1, closed: 0 }
end
