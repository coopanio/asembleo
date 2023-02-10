# frozen_string_literal: true

require 'test_helper'

class SessionsMailerTest < ActionMailer::TestCase
  test 'generate magic link email' do
    to = 'user@coopanio.com'
    token = create(:token)
    email = SessionsMailer.magic_link_email(to, token)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [to], email.to
    assert_includes email.body, "http://example.com/sessions/#{token.to_hash}/login"
    assert_match /Thanks,\n#{Rails.configuration.x.asembleo.title}/, email.body.to_s
    assert_equal ['sent'], token.reload.tags.map(&:value)
  end
end
