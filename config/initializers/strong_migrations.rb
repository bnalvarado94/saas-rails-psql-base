# Purpose: Strong Migrations configuration.
# Prevents dangerous database migrations from running in production.
# See: https://github.com/ankane/strong_migrations

# 0 means all migrations (including the very first) are checked.
# Update this to the latest migration version after you have an established baseline.
StrongMigrations.start_after = 0

# Target PostgreSQL version for migration safety checks
StrongMigrations.target_version = 17
