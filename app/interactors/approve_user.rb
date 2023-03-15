# frozen_string_literal: true

class ApproveUser < Actor
  input :hash, type: String

  def call
    validate
    return if receipt.approved?

    approve
    deliver if receipt.confirmed?
  end

  private

  def validate
    fail!(error: Errors::AccessDenied) unless salt == receipt.salt
  end

  def approve
    receipt.update!(approved: true, approved_at: Time.current)
    user.enabled! if receipt.confirmed?
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

  def salt
    data.second
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
