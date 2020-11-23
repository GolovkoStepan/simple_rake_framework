# frozen_string_literal: true

require 'yaml'
require 'sequel'

require_relative 'router'
require_relative 'controller'

module SimpleRackFramework
  class Application
    class << self
      attr_reader :db

      def call(env)
        if (route = @router.find_route(env))
          parse_url_params(route, env)
          controller = route.controller.new(env)
          action     = route.action
          make_response(controller, action)
        else
          not_found
        end
      end

      def routes
        router.routes
      end

      def define_routes(&block)
        router.instance_eval(&block)
      end

      def load_env!
        setup_database
        require_app
        require_routes
      end

      private

      def not_found
        [404, { 'Content-Type' => 'text/plain' }, ['Not found']]
      end

      def parse_url_params(route, env)
        env['srf.url_params'] = route.parse_url_params(env['PATH_INFO'])
      end

      def make_response(controller, action)
        controller.make_response(action)
      end

      def require_app
        Dir["#{SimpleRackFramework.root}/app/**/*.rb"].sort.each { |file| require file }
      end

      def require_routes
        require SimpleRackFramework.root.join('config/routes')
      end

      def setup_database
        database_config = YAML.load_file(SimpleRackFramework.root.join('config/database.yml'))
        database_config['database'] = SimpleRackFramework.root.join(database_config['database'])
        @db = Sequel.connect(database_config)
      end

      def router
        @router ||= Router.new
      end
    end
  end
end
