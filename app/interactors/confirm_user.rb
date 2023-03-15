# frozen_string_literal: true

class ConfirmUser < Actor
  input :hash, type: String

  def call
    return if receipt.confirmed?

    confirm
    deliver if receipt.approved?
  end

  private

  def confirm
    receipt.update!(confirmed: true, confirmed_at: Time.current)
    user.enabled! if receipt.approved?
  end

  def deliver
    UsersMailer.welcome_email(user.identifier, receipt, user_id).deliver_later
  end

  def receipt
    @receipt ||= IdentityReceipt.find(receipt_id)
  end

  def receipt_id
    return @receipt_id if defined?(@receipt_id)

    @receipt_id = data.first
  end

  def user
    @user ||= User.find(user_id)
  end

  def user_id
    data.last
  end

  def data
    @data ||= HashIdService.decode(hash)
  end
end
