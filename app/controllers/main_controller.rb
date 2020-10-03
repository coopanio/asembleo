# frozen_string_literal: true

class MainController < ApplicationController
  def index
    if current_user.present?
      redirect_to destination
      nil
    end
  end

  alias token current_user
end
