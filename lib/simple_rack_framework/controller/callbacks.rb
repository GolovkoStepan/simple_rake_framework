# frozen_string_literal: true

module Callbacks
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def before_callbacks
      @before_callbacks ||= {}
    end

    def before_action(method_name, options = {})
      @before_callbacks ||= {}
      @before_callbacks[method_name] = options
    end
  end

  module InstanceMethods
    def run_before_action_callbacks(action)
      return if self.class.before_callbacks.empty?

      self.class.before_callbacks.each do |key, value|
        send(key) if value[:only].is_a?(Array) && value[:only].include?(action.to_sym)
        send(key) if value[:only].is_a?(Symbol) && value[:only] == action.to_sym
      end
    end
  end
end
