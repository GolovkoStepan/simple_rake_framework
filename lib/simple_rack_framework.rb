# frozen_string_literal: true

require 'pathname'
require_relative 'simple_rack_framework/application'

module SimpleRackFramework
  class << self
    def application
      Application
    end

    def root
      Pathname.new(File.expand_path('..', __dir__))
    end

    def version
      '0.1.0'
    end
  end
end
