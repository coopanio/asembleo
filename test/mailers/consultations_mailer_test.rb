# frozen_string_literal: true

require 'test_helper'

class ConsultationsMailerTest < ActionMailer::TestCase
  test 'generate default tokens mail' do
    to = 'user@coopanio.com'
    tokens = [create(:token, role: :admin), create(:token, role: :manager)]
    email = ConsultationsMailer.default_tokens_email(to, tokens)

    assert_equal [to], email.to
    assert_match /- Admin token is <strong>#{tokens.first}<\/strong>./, email.body.to_s
    assert_match /- Manager token is <strong>#{tokens.second}<\/strong>./, email.body.to_s
    assert_match /Thanks,\n#{Rails.configuration.x.asembleo.title}/, email.body.to_s
  end
end
