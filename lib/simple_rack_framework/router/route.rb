# frozen_string_literal: true

class Route
  PATH_PARAMS_REGEXP = /:[a-zA-Z0-9_-]+/.freeze
  PATH_PARAM_GROUP   = '([0-9]+)'

  attr_accessor :method, :path_prototype, :path_regexp, :url_params_names, :controller, :action

  def initialize(method:, path_prototype:, controller:, action:)
    @method           = method
    @path_prototype   = path_prototype
    @controller       = controller
    @action           = action
    @url_params_names = find_url_params
    @path_regexp      = build_path_regexp
  end

  def match?(method, path)
    method.downcase == @method.to_s.downcase && @path_regexp.match?(path)
  end

  def parse_url_params(path)
    values = path.match(@path_regexp)
    values.nil? ? {} : @url_params_names.zip(values.captures).to_h
  end

  def to_s
    [
      "Method: #{@method.upcase}",
      "Path prototype: #{@path_prototype}",
      "Regexp: #{@path_regexp}",
      "URL params: #{@url_params_names.inspect}",
      "Controller: #{@controller}",
      "Action: #{@action}"
    ].join(' | ')
  end

  private

  def find_url_params
    @path_prototype.scan(PATH_PARAMS_REGEXP).map { |param| param.gsub!(':', '').to_sym }
  end

  def build_path_regexp
    path_regexp = @path_prototype.dup
    @url_params_names.each { |param| path_regexp.gsub!(":#{param}", PATH_PARAM_GROUP) }
    Regexp.new("^#{path_regexp}$")
  end
end
