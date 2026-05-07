require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.record = :new_episodes
  config.ignore_localhost = true
end

WebMock.disable_net_connect!(allow_localhost: true)
