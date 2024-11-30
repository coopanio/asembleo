# frozen_string_literal: true

require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :token

  setup do
    @token = create(:token, :admin)

    post sessions_url, params: { session: { identifier: token.to_hash } }
  end

  test 'should create event' do
    params = { event: { title: 'Test' } }

    post(events_url, params:)

    event = Event.first

    assert_response :redirect
    assert_equal event.title, params[:event][:title]
    assert_equal 2, Token.all.size
  end

  test 'should update event' do
    params = { event: { title: 'Test 2' } }
    event = create(:event, consultation: token.consultation)

    patch(event_url(event.id), params:)

    event = Event.first

    assert_response :redirect
    assert_equal 'Test 2', event.title
  end

  test 'should delete event' do
    event = create(:event, consultation: token.consultation)

    delete event_url(event.id)

    assert_response :redirect
    assert_equal 0, Event.all.size
  end

  test 'should create unaliased token' do
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)
    post sessions_url, params: { session: { identifier: token.to_hash } }

    post "/events/#{event.id}/tokens", params: {}

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 1, tokens.size
    assert_not tokens.first.alias
  end

  test 'should create multiple unaliased tokens' do
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)
    post sessions_url, params: { session: { identifier: token.to_hash } }

    census = StringIO.new("johndoe@exampl.es\rjanedoe@piraten.lu")

    assert_emails 0 do
      post "/events/#{event.id}/tokens", params: { value: Rack::Test::UploadedFile.new(census, 'text/csv', original_filename: 'census.csv'), multiple: 'true' }
    end

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 2, tokens.size
  end

  test 'should validate multiple tokens and fail' do
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)

    post sessions_url, params: { session: { identifier: token.to_hash } }

    file_content = <<~CSV
      "mohana@coop.mail; "
      kiran@coopanio.com
      giang@coopanio.com
      kelechi_9@coopanio.com
      blessing@examp.le
      masozi@coopanio.com
      chika-dawa.wanangwa@examp.le
      rathol@coopan.io
      "s.hozan99@coop.mail;"
      kelsey@coopanio.com
      xia@coopanio.com
    CSV
    census = StringIO.new(file_content)

    assert_emails 0 do
      post "/events/#{event.id}/tokens", params: { value: Rack::Test::UploadedFile.new(census, 'text/csv', original_filename: 'census.csv'), multiple: 'true', send: '1' }
    end

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 'Invalid identifiers. ("mohana@coop.mail; ", "s.hozan99@coop.mail;")', flash[:alert].message
    assert_equal 0, tokens.size
  end

  test 'should validate multiple tokens and fail (throught :value_raw)' do
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)

    post sessions_url, params: { session: { identifier: token.to_hash } }

    file_content = <<~CSV
      "mohana@coop.mail; "
      kiran@coopanio.com
      giang@coopanio.com
      kelechi_9@coopanio.com
      blessing@examp.le
      masozi@coopanio.com
      chika-dawa.wanangwa@examp.le
      rathol@coopan.io
      "s.hozan99@coop.mail;"
      kelsey@coopanio.com
      xia@coopanio.com
    CSV

    assert_emails 0 do
      post "/events/#{event.id}/tokens", params: { value_raw: file_content, multiple: 'true', send: '1' }
    end

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 'Invalid identifiers. ("mohana@coop.mail; ", "s.hozan99@coop.mail;")', flash[:alert].message
    assert_equal 0, tokens.size
  end

  test 'should validate multiple tokens handling BOM' do
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)

    post sessions_url, params: { session: { identifier: token.to_hash } }

    census = StringIO.new("\xEF\xBB\xBFmohana@coop.mail\x0D\x0As.hozan99@coop.mail\x0D\x0Amasozi@coopanio.com")

    assert_emails 3 do
      post "/events/#{event.id}/tokens", params: { value: Rack::Test::UploadedFile.new(census, 'text/csv', original_filename: 'census.csv'), multiple: 'true', send: '1' }
    end

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 3, tokens.size
  end

  test 'should validate multiple tokens handling BOM (through :value_raw)' do
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)

    post sessions_url, params: { session: { identifier: token.to_hash } }

    file_content = "\xEF\xBB\xBFmohana@coop.mail\x0D\x0As.hozan99@coop.mail\x0D\x0Amasozi@coopanio.com"

    assert_emails 3 do
      post "/events/#{event.id}/tokens", params: { value_raw: file_content, multiple: 'true', send: '1' }
    end

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 3, tokens.size
  end

  test 'should create an unaliased token and deliver it' do
    consultation = token.consultation
    event = create(:event, consultation: token.consultation)

    token.update!(role: :manager, event:)

    consultation.config.distribution = :email
    consultation.save!

    post sessions_url, params: { session: { identifier: token.to_hash } }

    assert_emails 1 do
      post "/events/#{event.id}/tokens", params: { value: 'johndoe@exampl.es', multiple: '0' }
    end

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 1, tokens.size
  end

  test 'should reenable disabled unaliased token' do
    event = create(:event, consultation: token.consultation)
    identifier = create(:token, consultation: token.consultation, event:, status: :disabled).to_s
    token.update!(role: :manager, event:)

    post sessions_url, params: { session: { identifier: token.to_hash } }

    post "/events/#{event.id}/tokens", params: { value: identifier }

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 1, tokens.size
    assert_equal identifier, tokens.first.to_s
    assert_predicate tokens.first, :enabled?
  end

  test 'should create aliased token' do
    event = create(:event, consultation: token.consultation)
    identifier = Token.sanitize(Faker::PhoneNumber.cell_phone)

    token.consultation.update!(config: { alias: :phone_number })
    token.update!(role: :manager, event:)
    post sessions_url, params: { session: { identifier: token.to_hash } }

    post "/events/#{event.id}/tokens", params: { value: identifier }

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 1, tokens.size
    assert_equal Token.sanitize(identifier), tokens.first.alias
  end

  test 'should reenable disabled aliased token' do
    event = create(:event, consultation: token.consultation)
    identifier = Token.sanitize(Faker::PhoneNumber.cell_phone)

    token.consultation.update!(config: { alias: :phone_number })
    create(:token, consultation: token.consultation, event:, alias: identifier, status: :disabled)
    token.update!(role: :manager, event:)

    post sessions_url, params: { session: { identifier: token.to_hash } }

    post "/events/#{event.id}/tokens", params: { value: identifier }

    tokens = Token.where(event:, role: :voter)

    assert_response :redirect
    assert_equal 1, tokens.size
    assert_equal identifier, tokens.first.alias
    assert_predicate tokens.first, :enabled?
  end

  test 'should create unaliased manager token in aliased consultation' do
    event = create(:event, consultation: token.consultation)

    token.consultation.update!(config: { alias: :phone_number })
    token.update!(role: :admin, event:)
    post sessions_url, params: { session: { identifier: token.to_hash } }

    post "/events/#{event.id}/tokens", params: { role: :manager }

    tokens = Token.where(event:, role: :manager)

    assert_response :redirect
    assert_equal 1, tokens.size
  end
end
