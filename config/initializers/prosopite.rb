return unless Rails.env.development?

Prosopite.rails_logger = true
Prosopite.raise        = false
