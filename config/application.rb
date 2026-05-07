require_relative "boot"

require "rails"
# Purpose: Only load frameworks needed for a JSON API.
# Excluded: action_cable, action_text, action_mailbox, action_view (not needed for pure API).
# Kept: action_mailer (transactional emails), active_storage (file uploads).
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module SaasRailsPsqlBase
  class Application < Rails::Application
    # Updated from 7.2 to 8.0 to match Rails 8.x defaults
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.active_job.queue_adapter = :solid_queue

    # Only loads a smaller set of middleware suitable for API only apps.
    config.api_only = true

    config.middleware.use ActionDispatch::Cookies

    # To use UUIDs as primary keys, uncomment this block and enable the pgcrypto
    # extension in your initial migration: enable_extension "pgcrypto"
    # config.generators do |g|
    #   g.orm :active_record, primary_key_type: :uuid
    # end
  end
end
