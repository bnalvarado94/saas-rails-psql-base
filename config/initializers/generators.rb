# Purpose: Configure Rails generators for API-only development.
# Skips assets, helpers, views — none needed for a JSON API.
# Defaults test framework to RSpec with FactoryBot fixtures.

Rails.application.config.generators do |g|
  g.test_framework :rspec, fixture: true
  g.fixture_replacement :factory_bot, dir: "spec/factories"
  g.assets false
  g.helper false
  g.view_specs false
  g.helper_specs false
  g.routing_specs false
  g.controller_specs false
  g.request_specs true
end
