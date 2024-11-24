# frozen_string_literal: true

require 'test_helper'

class SessionsMailerTest < ActionMailer::TestCase
  test 'generate magic link email' do
    to = 'user@coopanio.com'
    token = create(:token)
    email = SessionsMailer.magic_link_email(to, token.class.name, token.id, token.to_hash)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [to], email.to
    assert_includes email.body, "http://example.com/sessions/#{token.to_hash}/login"
    assert_includes email.body, "Thanks,\n#{Rails.configuration.x.asembleo.title}"
  end

  test 'generate magic link email with consultation customized notification' do
    to = 'user@coopanio.com'
    token = create(:token)
    notification = Consultation::Notification.new(subject: 'Custom subject', body: 'Custom body')
    email = SessionsMailer.magic_link_email(to, token.class.name, token.id, token.to_hash, notification:)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [to], email.to
    assert_includes email.body, "Custom body"
    assert_includes email.subject, "Custom subject"
  end

  test 'generate magic link email with consultation notification using interpolated variables' do
    to = 'user@coopanio.com'
    token = create(:token)
    body = """
    Root URL: %{root_url}
    Magic Link: %{magic_link_url}
    Token: %{token}
    """
    notification = Consultation::Notification.new(subject: 'Custom subject', body:)
    email = SessionsMailer.magic_link_email(to, token.class.name, token.id, token.to_hash, notification:)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [to], email.to
    assert email.body.raw_source.starts_with?("Root URL: http://example.com")
    assert_includes email.body, "http://example.com/sessions/#{token.to_hash}/login"
    assert_includes email.body, token.to_hash
    assert_includes email.subject, "Custom subject"
  end

  test 'generate magic link email with missing consultation customized notification subject' do
    to = 'user@coopanio.com'
    token = create(:token)
    notification = Consultation::Notification.new(body: 'Custom body')
    email = SessionsMailer.magic_link_email(to, token.class.name, token.id, token.to_hash, notification:)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [to], email.to
    assert_includes email.body, "Custom body"
    assert_includes email.subject, I18n.t('sessions_mailer.magic_link_email.subject')
  end
end
