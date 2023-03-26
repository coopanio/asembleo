# frozen_string_literal: true

class CreateUser < Actor
  input :email, type: String, allow_nil: false
  input :nid, type: String, allow_nil: false
  input :send_confirmation_email, type: [TrueClass, FalseClass], default: false

  output :user, type: User, allow_nil: true
  output :receipt, type: IdentityReceipt, allow_nil: true
  output :skip

  def call
    clean_nid
    validate

    if already_exists?
      self.skip = true

      return
    end

    create_user

    issue_receipt
    deliver if send_confirmation_email
  end

  private

  DNI_NIE_LENGTH = 9

  def clean_nid
    @nid = nid.upcase.gsub(/[^[:alnum:]]/, '')

    # We only support DNI and NIE, so we can safely assume that only up to the last 9
    # characters are relevant. The call to `to_s` is to ensure that we don't return a nil value.
    valid_length = nid.length
    valid_length = DNI_NIE_LENGTH if valid_length > DNI_NIE_LENGTH

    @nid = nid.slice(-valid_length, valid_length).to_s
  end

  def validate
    fail!(error: Errors::InvalidEmail) unless EmailValidator.valid?(email, mode: :strict)

    begin
      fail!(error: Errors::InvalidIdentity) unless DniNie.validate(nid)
    rescue ArgumentError
      fail!(error: Errors::InvalidIdentity)
    end
  end

  def already_exists?
    self.user = User.find_by(identifier: email)
    self.receipt = IdentityReceipt.generate(identifier: @nid)

    return true if user.present?
    return false if receipt.new_record?

    true
  end

  def create_user
    self.user = User.create!(identifier: email, role: :voter)
  end

  def issue_receipt
    receipt.save!
  end

  def deliver
    UsersMailer.confirmation_email(email, receipt, user.id).deliver_later

    User.where(role: :admin).each do |admin|
      UsersMailer.approval_email(admin.email, receipt, user.id, @nid, email).deliver_later
    end
  end
end
