# frozen_string_literal: true

module FlashConcern
  include ActiveSupport::Concern

  def success(message)
    flash[:notice] = Message.new(message)
  end

  def info(message)
    flash[:notice] = Message.new(message, type: :info)
  end

  def error(message)
    flash[:alert] = Message.new(message, type: :danger)
  end

  private

  class Message
    attr_reader :message, :type

    def initialize(message, type: :success)
      @message = message
      @type = type
    end
  end
end
