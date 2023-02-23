# frozen_string_literal: true

require 'test_helper'

class ConsultationsMailerTest < ActionMailer::TestCase
  test 'generate default tokens mail' do
    to = 'user@coopanio.com'
    consultation = create(:consultation)
    tokens = [create(:token, consultation:, role: :admin), create(:token, consultation:, role: :manager)]
    email = ConsultationsMailer.default_tokens_email(to, tokens)

    assert_equal [to], email.to
    assert_equal "Tokens created for #{consultation.title}", email.subject
    assert_includes email.body.to_s, "- Admin token is #{tokens.first}."
    assert_includes email.body.to_s, "- Manager token is #{tokens.second}."
    assert_includes email.body.to_s, "Thanks,\n#{Rails.configuration.x.asembleo.title}"
  end
end
