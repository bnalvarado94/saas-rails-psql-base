Prosopite.rails_logger  = true
Prosopite.raise         = true

RSpec.configure do |config|
  config.around(:each) do |example|
    Prosopite.scan
    example.run
    Prosopite.finish
  end
end
