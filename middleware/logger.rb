# frozen_string_literal: true

require 'logger'
require 'securerandom'

class ApplicationLogger
  def initialize(app, **options)
    File.open(options[:path], 'w') unless File.exist?(options[:path])
    @logger = Logger.new(options[:path] || $stdout)
    @app    = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    r_uuid = SecureRandom.uuid

    headers['Request-ID'] = r_uuid
    log_msg!(status: status, headers: headers, env: env, r_uuid: r_uuid)

    [status, headers, body]
  end

  private

  def log_msg!(status:, headers:, env:, r_uuid:)
    @logger.info("[#{r_uuid}] Request: #{env['REQUEST_METHOD']} #{env['REQUEST_URI']}")
    @logger.info("[#{r_uuid}] Handler: #{env['srf.controller'].class}##{env['srf.action']}")
    @logger.info("[#{r_uuid}] Parameters: #{env['srf.request_params']}")
    if status == 302
      @logger.info "[#{r_uuid}] Redirect to #{env['srf.redirect_location']}"
    else
      @logger.info("[#{r_uuid}] Response: #{status} [#{headers['Content-Type']}] #{env['srf.template_path']}")
    end
  end
end
