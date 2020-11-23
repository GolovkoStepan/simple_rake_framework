# frozen_string_literal: true

task :routes do
  require_relative 'config/environment'
  require 'tty-table'

  routes  = SimpleRackFramework.application.routes
  headers = ['Method', 'Path prototype', 'URL params', 'Controller', 'Action']
  rows    = routes.map do |route|
    [route.method, route.path_prototype, route.url_params_names, route.controller, route.action]
  end

  puts TTY::Table.new(headers, rows).render(:unicode)
end
