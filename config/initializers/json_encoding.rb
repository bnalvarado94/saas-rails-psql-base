# Purpose: Standardize JSON time format across all API responses.
# ISO 8601 is the universal standard for API datetime serialization.

ActiveSupport::JSON::Encoding.time_precision = 0
# Ensures Time objects serialize as ISO 8601 (e.g., "2024-01-15T09:30:00Z")
