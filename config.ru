# frozen_string_literal: true

require_relative 'config/environment'
require_relative 'middleware/logger'

use ApplicationLogger, path: File.expand_path('log/app.log', __dir__)
run SimpleRackFramework.application
