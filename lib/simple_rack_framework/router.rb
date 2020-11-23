# frozen_string_literal: true

require_relative 'router/route'

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def get(path, target_point)
    add_route method: :get, path: path, target_point: target_point
  end

  def post(path, target_point)
    add_route method: :post, path: path, target_point: target_point
  end

  def find_route(env)
    method = env['REQUEST_METHOD']
    path   = env['PATH_INFO']

    @routes.find { |route| route.match?(method, path) }
  end

  private

  def add_route(method:, path:, target_point:)
    controller, action = parse_target_point(target_point)

    @routes << Route.new(
      method: method.downcase.to_sym,
      path_prototype: path,
      controller: controller,
      action: action
    )
  end

  def parse_target_point(target_point)
    controller_name, action = target_point.split('#')
    [controller_klass(controller_name), action.downcase.to_sym]
  end

  def controller_klass(controller_name)
    Object.const_get("#{controller_name.capitalize}Controller")
  end
end
