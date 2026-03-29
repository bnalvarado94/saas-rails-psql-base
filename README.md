# SaaS Rails API Boilerplate

Production-ready Rails 8 API boilerplate for building SaaS products. Includes JWT authentication foundation, background jobs, rate limiting, CORS, structured logging, and a full CI pipeline — all containerized with Docker.

> **This is a boilerplate, not a scaffold.** It provides the architecture, conventions, and infrastructure wiring. You build the features on top.

---

## Stack

| Layer             | Technology                                                      |
| ----------------- | --------------------------------------------------------------- |
| Framework         | Rails 8.1.3 (API mode)                                          |
| Language          | Ruby 3.3.10                                                     |
| Database          | PostgreSQL 17                                                   |
| Background Jobs   | Solid Queue (Rails 8 native — no Redis required)                |
| Authentication    | JWT + BCrypt (custom, no Devise)                                |
| Serialization     | jsonapi-serializer                                              |
| Rate Limiting     | Rack::Attack                                                    |
| CORS              | rack-cors                                                       |
| Migration Safety  | strong_migrations                                               |
| Testing           | RSpec, FactoryBot, Shoulda Matchers, DatabaseCleaner, SimpleCov |
| Security Scanning | Brakeman, bundler-audit                                         |
| Code Quality      | RuboCop (rails-omakase)                                         |
| Containers        | Docker (multi-stage build, non-root user, health checks)        |

---

## Prerequisites

**Docker (recommended):**

- Docker Desktop 4.x or later (includes Docker Compose)

**Local development:**

- Ruby 3.3.10 (see `.ruby-version` — use rbenv or asdf)
- PostgreSQL 17
- Bundler 2.x

---

## Quick Start

### Docker (recommended)

```bash
git clone git@github.com:bnalvarado94/saas-rails-psql-base.git
cd saas-rails-psql-base

cp .env.example .env
# Edit .env — generate real values for SECRET_KEY_BASE and JWT_SECRET:
#   docker compose run --rm web rails secret

bin/dev
```

Visit [http://localhost:3000/up](http://localhost:3000/up) — a `200 OK` confirms the app is running.

> **After changing `Gemfile`:** run `docker compose build` to rebuild the image.

### Local (without Docker)

```bash
bin/setup          # Installs gems, creates .env from .env.example, prepares DB
bin/rails server   # Start the web server on port 3000
```

---

## Environment Variables

| Variable               | Required | Default                         | Description                                                  |
| ---------------------- | -------- | ------------------------------- | ------------------------------------------------------------ |
| `SECRET_KEY_BASE`      | Yes      | —                               | Rails encryption key. Generate with `rails secret`.          |
| `DATABASE_URL`         | Yes\*    | —                               | Full PostgreSQL connection string.                           |
| `POSTGRES_USER`        | Yes\*    | `postgres`                      | DB username (used by Docker Compose).                        |
| `POSTGRES_PASSWORD`    | Yes\*    | `password`                      | DB password (used by Docker Compose).                        |
| `POSTGRES_DB`          | Yes\*    | —                               | DB name (used by Docker Compose).                            |
| `JWT_SECRET`           | No       | Falls back to `SECRET_KEY_BASE` | Secret for signing JWT tokens. Set explicitly in production. |
| `JWT_EXPIRATION_HOURS` | No       | `24`                            | JWT token lifetime in hours.                                 |
| `ALLOWED_ORIGINS`      | No       | `http://localhost:3000`         | CORS-allowed origins, comma-separated.                       |
| `RACK_ATTACK_LIMIT`    | No       | `300`                           | Max requests per IP per 5 minutes.                           |
| `WEB_CONCURRENCY`      | No       | `2`                             | Puma worker processes (production only).                     |
| `RAILS_MAX_THREADS`    | No       | `5`                             | Puma threads per worker. Should match DB pool size.          |
| `RAILS_LOG_TO_STDOUT`  | No       | `true` in Docker                | Enables stdout logging for container environments.           |

_Use either `DATABASE_URL` **or** the `POSTGRES\__` variables — not both.

---

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb         # Thin base — inherits ActionController::API
│   ├── concerns/
│   │   ├── authenticatable.rb            # JWT auth — include in controllers that require login
│   │   └── error_handler.rb              # Centralized rescue_from for consistent JSON errors
│   └── api/
│       └── v1/
│           └── base_controller.rb        # Base for all v1 endpoints — includes both concerns
├── services/
│   ├── application_service.rb            # Base service object with .call() class method
│   └── jwt_service.rb                    # JWT encode/decode with configurable expiration
├── serializers/
│   └── base_serializer.rb                # jsonapi-serializer base with underscore key transform
├── models/
│   └── application_record.rb
├── jobs/
│   └── application_job.rb                # Solid Queue adapter configured
└── mailers/
    └── application_mailer.rb

config/
├── initializers/
│   ├── cors.rb                           # CORS — configured via ALLOWED_ORIGINS env var
│   ├── rack_attack.rb                    # Rate limiting — IP throttle + login endpoint throttle
│   ├── filter_parameter_logging.rb       # Scrubs passwords, tokens, API keys from logs
│   ├── generators.rb                     # Rails generators default to RSpec + FactoryBot
│   ├── json_encoding.rb                  # ISO 8601 datetime format for all JSON responses
│   └── strong_migrations.rb              # Prevents unsafe migrations on PostgreSQL 17
├── environments/
│   ├── development.rb
│   ├── test.rb
│   └── production.rb                     # Log tags, request IDs, production hardening
├── puma.rb                               # WEB_CONCURRENCY workers + preload_app! in production
├── queue.yml                             # Solid Queue configuration
└── recurring.yml                         # Solid Queue recurring job schedule (empty template)

spec/
├── support/
│   ├── database_cleaner.rb               # Transaction strategy + deletion for feature/system specs
│   └── request_helpers.rb                # json_response + auth_headers(user) helpers
└── requests/
    └── health_spec.rb                    # /up smoke test

bin/
├── dev                                   # Start all services via Docker Compose
├── setup                                 # Install deps, create .env, prepare DB
├── test                                  # Run RSpec with coverage
├── lint                                  # Run RuboCop with safe auto-correct
└── ci                                    # Run full CI pipeline locally
```

---

## Authentication

JWT-based authentication with a custom implementation (no Devise, no sessions).

**How it works:**

1. Generate a token using `JwtService.encode(user_id: user.id)`
2. Client includes the token in the `Authorization` header
3. `Authenticatable` concern decodes it and sets `@current_user` before the action runs

**Include in a controller:**

```ruby
class Api::V1::PostsController < Api::V1::BaseController
  # Authenticatable is already included via BaseController.
  # All actions in this controller require a valid JWT.

  def index
    render json: PostSerializer.new(current_user.posts).serializable_hash
  end
end
```

**Skip auth for a specific action:**

```ruby
class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_request!, only: [:login, :register]
end
```

**Token format:**

```
Authorization: Bearer <token>
```

**Auth endpoints are not included in this boilerplate.** Implement `POST /api/v1/auth/login` and `POST /api/v1/auth/register` when scaffolding your first resource. `JwtService` and `Authenticatable` are wired and ready.

---

## Service Objects

Use `ApplicationService` as a base for business logic:

```ruby
class Users::CreateService < ApplicationService
  def initialize(params)
    @params = params
  end

  def call
    User.create!(@params)
  end
end

# Call from a controller:
Users::CreateService.call(user_params)
```

---

## Serializers

Use `BaseSerializer` as a base for all serializers:

```ruby
class UserSerializer < BaseSerializer
  attributes :id, :email, :name, :created_at
  has_many :posts
end

# In a controller:
render json: UserSerializer.new(@user).serializable_hash
```

Keys are automatically transformed to underscore format. See [jsonapi-serializer docs](https://github.com/jsonapi-serializer/jsonapi-serializer) for full options.

---

## Background Jobs

Solid Queue is configured as the Active Job adapter. No Redis required — it runs on PostgreSQL.

```ruby
class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end

# Enqueue from anywhere:
WelcomeEmailJob.perform_later(user.id)
```

The `worker` service in Docker Compose runs `bundle exec rake solid_queue:start` automatically.

Recurring jobs can be scheduled in `config/recurring.yml`.

---

## Rate Limiting

Rack::Attack is configured with two throttles out of the box:

| Rule           | Limit        | Window     | Scope     |
| -------------- | ------------ | ---------- | --------- |
| General API    | 300 requests | 5 minutes  | Per IP    |
| Login endpoint | 5 requests   | 20 seconds | Per IP    |
| Login endpoint | 5 requests   | 60 seconds | Per email |

Throttled requests receive a `429 Too Many Requests` response with `Retry-After` and `X-RateLimit-*` headers.

Adjust the general limit via `RACK_ATTACK_LIMIT` env var. Edit `config/initializers/rack_attack.rb` to add custom rules.

---

## Running Tests

```bash
# Local
bin/test                                    # Full suite with coverage report
bin/test spec/requests/                     # Specific directory
bin/test spec/models/user_spec.rb           # Single file

# Via Docker
docker compose run --rm test
```

Coverage reports are written to `coverage/` by SimpleCov. In CI, the build fails if coverage drops below 80%.

**Request spec helpers available:**

```ruby
# json_response — parses the response body as JSON with symbol keys
expect(json_response[:status]).to eq("ok")

# auth_headers — generates a valid JWT Authorization header
get "/api/v1/posts", headers: auth_headers(user)
```

---

## Running CI Locally

```bash
bin/ci
```

Runs the same pipeline as GitHub Actions in sequence:

```
1. RuboCop lint
2. Brakeman security scan
3. bundler-audit dependency vulnerability check
4. RSpec with coverage (fails if < 80%)
```

---

## CI/CD Pipeline

Every push to `main` and every pull request triggers GitHub Actions:

```
scan_ruby ──┐
            ├──► test ──► upload coverage artifact
lint ───────┘
```

- `scan_ruby`: Brakeman static analysis + bundler-audit CVE check
- `lint`: RuboCop
- `test`: RSpec with SimpleCov — coverage report uploaded as a GitHub artifact (7-day retention)

In-progress runs on the same branch are automatically cancelled to save runner minutes.

---

## Code Quality

**RuboCop** is configured with `rubocop-rails-omakase` as the base ruleset, with these project-level overrides:

- `Style/Documentation` — disabled (no need to document every class in an API)
- `Metrics/MethodLength` — max 20 lines
- `Metrics/BlockLength` — relaxed for `spec/`, `config/`, and `lib/tasks/`

```bash
bin/lint                               # Auto-correct safe issues
bin/rubocop                            # Check only, no changes

# Generate a todo file to progressively address existing offenses:
bundle exec rubocop --auto-gen-config
# Then add to .rubocop.yml:
#   inherit_from: .rubocop_todo.yml
```

---

## Docker

The Dockerfile uses a **multi-stage build**:

| Stage        | Purpose                                                                 |
| ------------ | ----------------------------------------------------------------------- |
| `builder`    | Installs build tools, compiles native gems, precompiles Bootsnap cache  |
| `production` | Minimal runtime image — no build tools, non-root `rails` user, jemalloc |

**Key characteristics:**

- Non-root user (`rails`) — the container runs without root privileges
- jemalloc — reduces memory fragmentation in production
- Health check on `/up` — Docker and load balancers can detect unhealthy containers
- `BUNDLE_WITHOUT` build arg — dev builds include all gems; production builds exclude `development:test`

**Docker Compose services:**

| Service  | Purpose                              |
| -------- | ------------------------------------ |
| `db`     | PostgreSQL 17                        |
| `web`    | Rails API server (Puma)              |
| `worker` | Solid Queue background job processor |
| `test`   | RSpec test runner (profile: `test`)  |

```bash
bin/dev                                # Start web + worker + db
docker compose run --rm test           # Run test suite
docker compose build                   # Rebuild after Gemfile changes
docker compose down -v                 # Stop and remove volumes
```

---

## Deployment

The `Procfile` is compatible with Heroku, Render, and Fly.io:

```
web:    bundle exec puma -C config/puma.rb
worker: bundle exec rake solid_queue:start
```

**Minimum required production environment variables:**

```
SECRET_KEY_BASE=<rails secret>
DATABASE_URL=postgres://...
JWT_SECRET=<separate secret>
ALLOWED_ORIGINS=https://yourdomain.com
```

The Dockerfile is production-ready as-is. For orchestrated environments (Kubernetes, ECS), use the `production` stage directly.

---

## Architecture Decisions

| Decision                         | Rationale                                                                                               |
| -------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **No Devise**                    | JWT auth is simpler for pure APIs. Devise adds session and cookie complexity that isn't needed.         |
| **Solid Queue over Sidekiq**     | Rails 8 native. Uses PostgreSQL — eliminates Redis as an operational dependency.                        |
| **jsonapi-serializer**           | JSON:API spec compliance, explicit attribute declaration, faster than ActiveModelSerializers.           |
| **Service objects**              | Keeps controllers thin. `ApplicationService.call()` pattern makes business logic testable in isolation. |
| **rack-attack**                  | Rate limiting at the middleware level — before requests reach the application stack.                    |
| **strong_migrations**            | Enforces safe migration patterns (concurrent indexes, etc.) at development time, not in production.     |
| **Multi-stage Docker**           | Production image is ~60% smaller than a single-stage build. Non-root user by default.                   |
| **Custom JWT over oauth gems**   | Fewer dependencies, full control over token structure and expiration policy.                            |
| **SimpleCov at 80%**             | Enforces coverage discipline without being unreasonably strict for a growing codebase.                  |
| **API versioning at `/api/v1/`** | Allows non-breaking v2 rollout in the future without disrupting existing clients.                       |

---

## Developer Scripts

| Script            | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `bin/dev`         | Start all services (web + worker + db) via Docker Compose         |
| `bin/setup`       | Install gems, create `.env` from `.env.example`, prepare database |
| `bin/test [args]` | Run RSpec with coverage. Passes extra args to rspec.              |
| `bin/lint [args]` | Run RuboCop with safe auto-correct (`-a`).                        |
| `bin/ci`          | Run full CI pipeline locally (lint → security → audit → tests)    |
| `bin/rubocop`     | Run RuboCop check only (no changes)                               |
| `bin/brakeman`    | Run Brakeman security scan                                        |

---

## Author

**Brian Alvarado** — Senior Full-Stack Engineer

- GitHub: [@bnalvarado94](https://github.com/bnalvarado94)
