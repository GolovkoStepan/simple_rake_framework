# frozen_string_literal: true

require_relative 'view'
require_relative 'controller/callbacks'

module SimpleRackFramework
  class Controller
    include Callbacks

    DEFAULT_HEADERS = {
      'Content-Type' => 'text/html'
    }.freeze

    attr_reader :name, :request, :response

    def initialize(env)
      @name     = extract_name
      @request  = Rack::Request.new(env)
      @response = Rack::Response.new
      @headers  = {}
    end

    def make_response(action)
      execute_request(action)
      prepare_response
      complete_response
    end

    protected

    attr_reader :headers

    def before_action(method_name, options = {})
      @before_callbacks[method_name] = options
    end

    def params
      @request.env['srf.request_params']
    end

    def status(code)
      @response.status = code
    end

    def redirect_to(location)
      @request.env['srf.redirect_location'] = location
    end

    def render(arg)
      case arg.class.to_s
      when 'String'
        @request.env['srf.template'] = template
      when 'Hash'
        @request.env['srf.render_type'], @request.env['srf.render_content'] = arg.first
        @response.status = arg[:status] if arg[:status]
      else
        raise ArgumentError, "Invalid class #{arg.class} for render argument"
      end
    end

    private

    def collect_headers
      headers = DEFAULT_HEADERS.merge(@headers)
      headers['Content-Type'] = @request.env['srf.render_content_type'] if @request.env['srf.render_content_type']
      headers.each { |key, value| @response[key] = value }
    end

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name]&.downcase
    end

    def execute_request(action)
      @request.env['srf.controller'] = self
      @request.env['srf.action'] = action
      @request.env['srf.request_params'] = @request.env['srf.url_params'].merge(@request.params)
      @request.env['srf.request_params'].transform_keys!(&:to_sym)

      run_before_action_callbacks(action)
      send(action)
    end

    def prepare_response
      if (location = @request.env['srf.redirect_location'])
        @response.redirect location
      else
        body = View.new(@request.env).render(binding)
        @response.write(body)
      end
    end

    def complete_response
      collect_headers
      @response.finish
    end
  end
end
