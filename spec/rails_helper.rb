# Purpose: Rails-specific RSpec configuration.
# Loads support files, configures DatabaseCleaner, FactoryBot, and Shoulda matchers.

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Prevent running specs against production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Load all support files
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Ensure test DB schema is current
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
