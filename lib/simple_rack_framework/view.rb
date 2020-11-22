# frozen_string_literal: true

require 'erb'
require 'json'

module SimpleRackFramework
  class View
    VIEW_BASE_PATH = 'app/views'

    def initialize(env)
      @env = env
    end

    def render(binding)
      if @env['srf.render_type'] && @env['srf.render_content']
        return send("render_#{@env['srf.render_type']}", @env['srf.render_content'])
      end

      template = File.read(template_path)
      ERB.new(template).result(binding)
    end

    private

    def controller
      @env['srf.controller']
    end

    def action
      @env['srf.action']
    end

    def template
      @env['srf.template']
    end

    def template_path
      path = template || [controller.name, action].join('/')
      path = "#{path}.html.erb"
      @env['srf.template_path'] = path
      SimpleRackFramework.root.join(VIEW_BASE_PATH, path)
    end

    def render_plain(content)
      @env['srf.render_content_type'] = 'text/plain'
      content
    end

    def render_json(content)
      @env['srf.render_content_type'] = 'application/json'
      JSON.generate(content)
    end
  end
end
