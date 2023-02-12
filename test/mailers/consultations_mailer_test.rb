# frozen_string_literal: true

require 'test_helper'

class ConsultationsMailerTest < ActionMailer::TestCase
  test 'generate default tokens mail' do
    to = 'user@coopanio.com'
    tokens = [create(:token, role: :admin), create(:token, role: :manager)]
    email = ConsultationsMailer.default_tokens_email(to, tokens)

    assert_equal [to], email.to
    assert_includes email.body.to_s, "- Admin token is <strong>#{tokens.first}</strong>."
    assert_includes email.body.to_s, "- Manager token is <strong>#{tokens.second}</strong>."
    assert_includes email.body.to_s, "Thanks,\n#{Rails.configuration.x.asembleo.title}"
  end
end
