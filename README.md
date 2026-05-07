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
| Authorization     | Pundit (policy objects)                                         |
| Pagination        | Pagy (limit 25, max 100)                                        |
| Full-text Search  | pg_search (PostgreSQL native, tsearch)                          |
| Audit Trail       | PaperTrail (change history for ActiveRecord models)             |
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
│   ├── application_controller.rb              # Thin base — inherits ActionController::API
│   ├── concerns/
│   │   ├── authenticatable.rb                 # JWT auth — include in controllers that require login
│   │   └── error_handler.rb                   # Centralized rescue_from for consistent JSON errors
│   └── api/
│       └── v1/
│           ├── base_controller.rb             # Base for all v1 endpoints — includes both concerns
│           └── auth/
│               └── sessions_controller.rb     # login / refresh / logout endpoints
├── models/
│   ├── application_record.rb
│   ├── user.rb                                # Email + BCrypt password, refresh_tokens association
│   └── refresh_token.rb                       # Rotating refresh tokens with family-based theft detection
├── policies/
│   └── application_policy.rb                  # Pundit base policy — all actions deny by default
├── services/
│   ├── application_service.rb                 # Base service object with .call() class method
│   ├── jwt_service.rb                         # JWT encode/decode, 15-minute TTL, HS256
│   └── auth/
│       ├── login_service.rb                   # Validates credentials, issues access + refresh tokens
│       ├── refresh_service.rb                 # Rotates refresh token, detects reuse/theft
│       └── logout_service.rb                  # Revokes entire refresh token family
├── serializers/
│   └── base_serializer.rb                     # jsonapi-serializer base with underscore key transform
├── jobs/
│   └── application_job.rb                     # Solid Queue adapter configured
└── mailers/
    └── application_mailer.rb

config/
├── initializers/
│   ├── cors.rb                                # CORS — configured via ALLOWED_ORIGINS env var
│   ├── rack_attack.rb                         # Rate limiting — IP throttle + login endpoint throttle
│   ├── filter_parameter_logging.rb            # Scrubs passwords, tokens, API keys from logs
│   ├── generators.rb                          # Rails generators default to RSpec + FactoryBot
│   ├── json_encoding.rb                       # ISO 8601 datetime format for all JSON responses
│   ├── pagy.rb                                # Pagination defaults (limit: 25, max: 100)
│   ├── pg_search.rb                           # Full-text search — tsearch with English dictionary
│   └── strong_migrations.rb                   # Prevents unsafe migrations on PostgreSQL 17
├── environments/
│   ├── development.rb
│   ├── test.rb
│   └── production.rb                          # Log tags, request IDs, production hardening
├── puma.rb                                    # WEB_CONCURRENCY workers + preload_app! in production
├── queue.yml                                  # Solid Queue configuration
└── recurring.yml                              # Solid Queue recurring job schedule (empty template)

spec/
├── factories/
│   ├── users.rb
│   └── refresh_tokens.rb
├── models/
│   ├── user_spec.rb
│   └── refresh_token_spec.rb
├── requests/
│   ├── health_spec.rb                         # /up smoke test
│   └── api/v1/auth/
│       └── sessions_spec.rb                   # login / refresh / logout request specs
└── support/
    ├── database_cleaner.rb                    # Transaction strategy + deletion for feature/system specs
    ├── request_helpers.rb                     # json_response + auth_headers(user) helpers
    └── vcr.rb                                 # VCR cassette configuration for HTTP stubs

bin/
├── dev                                   # Start all services via Docker Compose
├── setup                                 # Install deps, create .env, prepare DB
├── test                                  # Run RSpec with coverage
├── lint                                  # Run RuboCop with safe auto-correct
└── ci                                    # Run full CI pipeline locally
```

---

## Authentication

JWT + rotating refresh token authentication with a custom implementation (no Devise, no sessions).

**How it works:**

1. Client calls `POST /api/v1/auth/login` with email and password
2. Server returns a short-lived **access token** (JWT, 15 min) in the response body and a **refresh token** in an HttpOnly cookie
3. Client includes the access token in the `Authorization: Bearer <token>` header for protected requests
4. When the access token expires, client calls `POST /api/v1/auth/refresh` — the server rotates the refresh token and issues a new access token
5. On logout, `DELETE /api/v1/auth/logout` revokes the entire refresh token family

**Auth endpoints:**

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/auth/login` | Authenticate and receive tokens |
| `POST` | `/api/v1/auth/refresh` | Rotate refresh token and get a new access token |
| `DELETE` | `/api/v1/auth/logout` | Revoke all refresh tokens for the session |

**Login response:**

```json
{
  "access_token": "<jwt>",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": { "id": 1, "email": "...", "first_name": "...", "last_name": "..." }
}
```

**Refresh token security:**

- Tokens are stored as SHA-256 digests — raw value is never persisted
- Each use rotates the token (old token is marked `used_at`)
- Reuse of a consumed token triggers **family revocation** (theft detection)
- Tokens carry `ip_address` and `user_agent` for audit purposes

**Include auth in a controller:**

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
class Api::V1::SomeController < Api::V1::BaseController
  skip_before_action :authenticate_request!, only: [:public_action]
end
```

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

## Authorization

Pundit is configured with an `ApplicationPolicy` base that denies all actions by default.

```ruby
class PostPolicy < ApplicationPolicy
  def index?  = true           # Anyone authenticated can list
  def show?   = record.user == user
  def create? = true
  def update? = record.user == user
  def destroy? = record.user == user

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(user: user)
  end
end

# In a controller:
class Api::V1::PostsController < Api::V1::BaseController
  def show
    @post = Post.find(params[:id])
    authorize @post
    render json: PostSerializer.new(@post).serializable_hash
  end

  def index
    @posts = policy_scope(Post)
    render json: PostSerializer.new(@posts).serializable_hash
  end
end
```

See the [Pundit docs](https://github.com/varvet/pundit) for full options including scopes and headless policies.

---

## Pagination

Pagy is configured with a default page size of 25 (max 100).

```ruby
class Api::V1::PostsController < Api::V1::BaseController
  include Pagy::Backend

  def index
    @pagy, @posts = pagy(Post.all)
    render json: {
      data: PostSerializer.new(@posts).serializable_hash,
      meta: pagy_metadata(@pagy)
    }
  end
end
```

Pass `?page=2&limit=50` as query params. See [Pagy docs](https://ddnexus.github.io/pagy/) for cursor, keyset, and other strategies.

---

## Full-text Search

`pg_search` is configured to use PostgreSQL's native `tsearch` with an English dictionary.

```ruby
class Post < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_title_and_body,
    against: [:title, :body],
    using: { tsearch: { dictionary: "english" } }
end

# In a controller:
Post.search_by_title_and_body(params[:q])
```

For multi-model search, use `PgSearch.multisearch`. See [pg_search docs](https://github.com/Casecommons/pg_search).

---

## Audit Trail

PaperTrail records every create, update, and destroy for any model you opt in to.

```ruby
class Post < ApplicationRecord
  has_paper_trail
end

# Inspect history:
post.versions                        # All versions
post.versions.last.reify            # Restore previous state
PaperTrail::Version.where(item_type: "Post")
```

PaperTrail is installed but **not enabled globally** — add `has_paper_trail` only to models that need change history.

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
bin/dev                                           # Start web + worker + db
docker compose run --rm test                      # Run RSpec test suite
docker compose run --rm web bundle exec rubocop   # Run RuboCop linter
docker compose run --rm web bundle exec brakeman  # Run Brakeman security scan
docker compose build                              # Rebuild after Gemfile changes
docker compose down -v                            # Stop and remove volumes
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
| **JWT at 15 min + refresh token** | Short-lived JWTs cannot be revoked; refresh tokens (30 days, rotated on each use) handle session longevity safely. |
| **Refresh token in HttpOnly cookie** | Prevents JavaScript access to the refresh token — mitigates XSS token theft.                      |
| **Family-based theft detection** | Reuse of a consumed refresh token revokes the entire token family, protecting users on token compromise. |
| **Pundit for authorization**     | Policy objects keep authorization logic co-located with the resource and fully testable in isolation.   |
| **Pagy for pagination**          | 40× faster than Kaminari/WillPaginate, zero monkey-patching, works at the DB level.                    |
| **pg_search**                    | Full-text search using native PostgreSQL `tsvector` — no external search index needed.                  |
| **PaperTrail (opt-in)**          | Audit trail without a global performance penalty — enable per model as needed.                          |
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
