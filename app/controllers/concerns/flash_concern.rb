# frozen_string_literal: true

module FlashConcern
  include ActiveSupport::Concern

  def success(message)
    flash[:notice] = Message.new(message)
  end

  def info(message)
    flash[:notice] = Message.new(message, :info)
  end

  def error(message)
    flash[:alert] = Message.new(message, :error)
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
