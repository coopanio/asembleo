# frozen_string_literal: true

module TranslateStoreModel
  class Builder
    attr_accessor :i18n_scope, :i18n_key, :model, :attribute

    def initialize(model, attribute)
      @model = model
      @attribute = attribute

      yield(self) if block_given?
    end

    def i18n_scope
      @i18n_scope ||= "#{model.i18n_scope}.attributes"
    end

    def i18n_key
      @i18n_key ||= "#{attribute}_list"
    end

    def i18n_location(key)
      "#{model.model_name.i18n_key}.#{i18n_key}.#{key}"
    end

    def i18n_default_location(key)
      :"attributes.#{i18n_key}.#{key}"
    end

    def method_name_plural
      @method_name_plural ||= "translated_#{attribute.to_s.pluralize}"
    end

    def enum_instance_method
      model.new.public_send("#{attribute}_values")
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def translate_enum(attribute, &block)
      builder = Builder.new(self, attribute, &block)

      define_singleton_method(builder.method_name_plural) do |throw: false, raise: false, locale: nil, **options|
        builder.enum_instance_method.map do |key, value|
          opts = { default: builder.i18n_default_location(key) }.merge(options)
          translated = I18n.translate("#{builder.i18n_scope}.#{builder.i18n_location(key)}", throw: throw, raise: raise, locale: locale, **opts)

          [translated, key, value]
        end
      end
    end
  end
end
