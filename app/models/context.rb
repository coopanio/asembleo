# frozen_string_literal: true

class Context
  attr_accessor :identity
  attr_writer :consultation_id, :event_id

  def self.method_missing(method, *args, &)
    context.send(method, *args, &)
  end

  def self.respond_to_missing?(method, *)
    context.respond_to?(method)
  end

  def self.context
    Thread.current[:context] ||= Context.new
  end

  def self.reset
    Thread.current[:context] = nil
  end

  def self.to_h
    {
      consultation_id: consultation_id,
      event_id: event_id,
      identity: identity
    }
  end

  def admin?
    return false if identity.nil?

    identity.admin?
  end

  def manager?
    return false if identity.nil?

    identity.manager?
  end

  def token?
    identity.is_a?(Token)
  end

  def user?
    identity.is_a?(User)
  end

  def voter?
    return false if identity.nil?

    identity.voter?
  end

  def consultation_id
    return @consultation_id if defined?(@consultation_id)
    return @consultation_id = identity.consultation_id if identity.respond_to?(:consultation_id)

    @consultation_id = nil
  end

  def event_id
    return @event_id if defined?(@event_id)
    return @event_id = identity.event_id if identity.respond_to?(:event_id)

    @event_id = nil
  end
end
