# frozen_string_literal: true

class UsersController < ApplicationController
  def new; end

  def create
    result = CreateUser.result(user_params.merge(send_confirmation_email: true))
    raise result.error if result.failure?

    success(I18n.t('users.user_created'))
    redirect_to root_path
  end

  def confirm
    result = ConfirmUser.result(confirmation_params)
    raise result.error if result.failure?

    success(I18n.t('users.user_confirmed'))
    redirect_to root_path
  end

  def approve
    result = ApproveUser.result(confirmation_params)
    raise result.error if result.failure?

    success(I18n.t('users.user_approved'))
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :nid)
  end

  def confirmation_params
    params.permit(:hash)
  end
end
