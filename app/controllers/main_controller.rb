# frozen_string_literal: true

class MainController < ApplicationController
  include DestinationConcern

  def index
    if current_user.present?
      redirect_to destination
      return
    end
  end

  private

  alias token current_user
end
