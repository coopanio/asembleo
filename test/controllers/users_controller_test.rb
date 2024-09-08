# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ControllerTestCase
  setup do
    @email = 'example@example.com'
    @nid = DniNie.random_nie
    @fingerprint = FingerprintService.generate(@nid)

    @token = create_admin_user
    login_user
  end

  subject { post users_url, params: { user: { email: @email, nid: @nid } } }

  test 'should create user' do
    subject

    assert_response :redirect
    assert_equal(
      'Account creation request registered succesfully. You will receive an email to confirmate it if everything is correct.', flash[:notice].message
    )

    User.where(role: :voter).tap do |users|
      assert_equal 1, users.length
      assert_equal @email, users.first.identifier
      assert_predicate users.first, :disabled?
    end

    IdentityReceipt.all.tap do |receipts|
      assert_equal 1, receipts.length
      assert_equal @fingerprint, receipts.first.fingerprint
    end

    assert_enqueued_emails 2
  end

  test 'should not create user if email is invalid' do
    @email = 'invalid-email'
    subject

    assert_response :redirect
    assert_equal('Invalid email.', flash[:alert].message)

    User.where(role: :voter).tap do |users|
      assert_equal 0, users.length
    end

    IdentityReceipt.all.tap do |receipts|
      assert_equal 0, receipts.length
    end

    assert_enqueued_emails 0
  end

  test 'should not create user if nid is invalid' do
    @nid = 'invalid-nid'
    subject

    assert_response :redirect
    assert_equal('Invalid identity document.', flash[:alert].message)

    User.where(role: :voter).tap do |users|
      assert_equal 0, users.length
    end

    IdentityReceipt.all.tap do |receipts|
      assert_equal 0, receipts.length
    end

    assert_enqueued_emails 0
  end

  test 'should not create user if email is already taken' do
    result = CreateUser.result(nid: @nid, email: @email, send_confirmation_email: false)

    subject

    assert_response :redirect
    assert_equal('Account creation request registered succesfully. You will receive an email to confirmate it if everything is correct.', flash[:notice].message) # Spoiler: it's not :)

    User.where(identifier: @email).tap do |users|
      assert_equal 1, users.length
      assert_equal result.user.id, users.first.id
    end

    IdentityReceipt.all.tap do |receipts|
      assert_equal 1, receipts.length
      assert_equal result.receipt.id, receipts.first.id
    end

    assert_enqueued_emails 0
  end

  test 'should not create user if nid is already taken' do
    result = CreateUser.result(nid: @nid, email: @email, send_confirmation_email: false)

    subject

    assert_response :redirect
    assert_equal('Account creation request registered succesfully. You will receive an email to confirmate it if everything is correct.', flash[:notice].message) # Spoiler: it's not :)

    User.where(identifier: @email).tap do |users|
      assert_equal 1, users.length
      assert_equal result.user.id, users.first.id
    end

    IdentityReceipt.all.tap do |receipts|
      assert_equal 1, receipts.length
      assert_equal result.receipt.id, receipts.first.id
    end

    assert_enqueued_emails 0
  end

  class E2ETest < ControllerTestCase
    setup do
      @email = 'example@example.com'
      @nid = DniNie.random_dni

      @token = create_admin_user
      login_user
    end

    def extract_urls_from_emails
      deliveries_content = ActionMailer::Base.deliveries.map(&:body).join
      ActionMailer::Base.deliveries.clear

      URI.extract(deliveries_content, %w[http https])
    end

    test 'should activate user' do
      perform_enqueued_jobs do
        post users_url, params: { user: { email: @email, nid: @nid } }
      end

      User.find_by(identifier: @email).tap do |user|
        assert_predicate user, :disabled?
      end

      assert_emails 2

      urls = extract_urls_from_emails
      urls.shuffle!

      assert_equal 2, urls.length

      perform_enqueued_jobs do
        urls.each do |url|
          get url

          assert_response :redirect
          if url.include?('confirmations')
            assert_equal("Account confirmed. You will receive an email with the admins' approval.",
                         flash[:notice].message)
          else
            assert_equal('Account approved.', flash[:notice].message)
          end
        end
      end

      assert_emails 1

      user = User.find_by(identifier: @email)
      assert_predicate user, :enabled?

      urls = extract_urls_from_emails
      assert_equal 1, urls.length

      get urls.first

      assert_response :redirect
      assert_equal user.id, session[:identity_id]
      assert_equal user.class.name, session[:identity_type]
    end
  end
end
