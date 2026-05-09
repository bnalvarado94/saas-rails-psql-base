source "https://rubygems.org"

# ─── Core ───────────────────────────────
gem "rails", "~> 8.1.3"                       # Main web framework
gem "pg", "~> 1.1"                             # PostgreSQL adapter
gem "puma", ">= 5.0"                           # Puma web server
gem "bootsnap", require: false                 # Speeds up boot by caching files
gem "tzinfo-data", platforms: %i[ windows jruby ] # Timezone data for Windows/JRuby
gem "strong_migrations"                        # Prevents dangerous migrations in production
gem "solid_queue"                              # Active Job backend built on PostgreSQL (no Redis)

# ─── Security / Middleware ───────────────
gem "rack-cors"                                # Handles CORS for APIs
gem "rack-attack"                              # Rate limiting and request throttling

# ─── Auth ───────────────────────────────
gem "jwt"                                      # JSON Web Tokens for stateless authentication
gem "bcrypt", "~> 3.1.7"                       # Secure password hashing

# ─── Serializers ────────────────────────
gem "jsonapi-serializer"                       # Fast and declarative JSON:API serialization

# ─── Authorization ──────────────────────
gem "pundit"                                   # Policy-based authorization (Policy Objects)

# ─── Pagination ─────────────────────────
gem "pagy"                                     # Lightweight and fast pagination

# ─── Search ─────────────────────────────
# gem "pg_search"                              # Uncomment when needed. Add `include PgSearch::Model`
#                                              # to any model, then define pg_search_scope.
#                                              # Also uncomment config/initializers/pg_search.rb.

# ─── Business Logic ─────────────────────
# gem "interactor"                             # Uncomment when needed. Service objects via Interactor::Organizer.
# gem "enumerize"                              # Uncomment when needed. Enumerated attributes with I18n support.
# gem "aasm"                                   # Uncomment when needed. State machines for ActiveRecord models.

# ─── Auditing ───────────────────────────
gem "paper_trail"                              # Change history and audit trail for ActiveRecord models

# ─── File Uploads (optional) ────────────
# gem "shrine"                                 # Uncomment if you need file uploads (alternative to ActiveStorage)

# ─── OAuth (optional) ───────────────────
# gem "doorkeeper"                             # Uncomment if you need an OAuth2 provider
# gem "omniauth"                               # Uncomment if you need login with external providers (Google, GitHub, etc)
# gem "omniauth-rails_csrf_protection"         # Uncomment if you need login with external providers (Google, GitHub, etc)

group :development do
  # ─── Environment ────────────────────────
  gem "dotenv-rails"                           # Loads environment variables from .env

  # ─── Email ──────────────────────────────
  gem "letter_opener"                          # Opens emails in the browser instead of sending them
end

group :development, :test do
  # ─── Testing Framework ──────────────────
  gem "rspec-rails"                            # BDD testing framework for Rails
  gem "factory_bot_rails"                      # Factories for creating test objects
  gem "faker"                                  # Generates realistic fake data for tests

  # ─── Debugging ──────────────────────────
  gem "pry-rails"                              # Replaces IRB with Pry in the Rails console
  gem "pry-byebug"                             # Breakpoints and step-through debugging with Pry
  gem "debug", platforms: %i[ mri windows ]   # Standard Ruby debugger

  # ─── Code Quality ───────────────────────
  gem "brakeman", require: false               # Static security analysis for Rails
  gem "bundler-audit", require: false          # Audits dependencies for known vulnerabilities
  gem "rubocop-rails-omakase", require: false  # Omakase-style Ruby linter (DHH)

  # ─── Performance ────────────────────────
  gem "prosopite"                              # Detects N+1 queries; logs in dev, raises in test
  gem "pg_query"                               # Required by prosopite for query fingerprinting
end

group :test do
  # ─── Matchers & Cleanup ─────────────────
  gem "shoulda-matchers"                       # One-liner matchers for models and controllers
  gem "database_cleaner-active_record"         # Cleans the database between tests
  gem "simplecov", require: false              # Test coverage reporting

  # ─── Time & HTTP Mocking ────────────────
  gem "timecop"                                # Freeze or travel through time in tests
  gem "vcr"                                    # Records and replays HTTP interactions in tests
  gem "webmock"                                # Intercepts and stubs HTTP requests in tests
end
