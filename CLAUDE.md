# CLAUDE.md

> This file is read automatically by Claude Code at the start of every session.
> Keeping it up to date is the developer's responsibility, not the AI's.

---

## Project

**Name:** saas-rails-psql-base
**Description:** Production-ready Rails 8 API boilerplate for building SaaS products — authentication, authorization, pagination, search, audit trail, and background jobs wired up out of the box.
**Stack:** Rails 8.1.3 / Ruby 3.3.10 / PostgreSQL 17 / Docker
**Dev environment:** Docker + Puma (`bin/dev`)

---

## Essential commands

```bash
# Start environment
bin/dev                                         # Docker Compose (recommended)
bin/rails server                                # Local without Docker

# Run tests
bundle exec rspec

# Lint / type check
bundle exec rubocop

# Check command (used by skills to verify integrity)
bundle exec rspec && bundle exec rubocop --autocorrect-all

# Security scan
bundle exec brakeman --no-pager
bundle exec bundler-audit check --update
```

> **IMPORTANT for skills:** The check command is defined above.
> Skills (`implement-plan-audited`, `fix-bug`, etc.) look for it here before executing.

---

## Architecture

### Directory structure
```
app/
  controllers/
    api/v1/
      auth/
        sessions_controller.rb       # login, refresh, logout (public)
        registrations_controller.rb  # register (public)
        confirmations_controller.rb  # confirm email (public)
        passwords_controller.rb      # request + confirm password reset (public)
      users_controller.rb            # user profile (authenticated)
      base_controller.rb             # JWT auth + Pundit wired up
    concerns/
      authenticatable.rb             # JWT decode + current_user
      error_handler.rb               # centralized error rendering
  mailers/
    user_mailer.rb                   # confirmation + password reset emails
  models/
    user.rb
    refresh_token.rb
  policies/
    application_policy.rb            # Pundit base (deny by default)
    user_policy.rb                   # user resource authorization
  serializers/
    base_serializer.rb               # jsonapi-serializer base
    user_serializer.rb
  services/
    auth/
      login_service.rb
      logout_service.rb
      refresh_service.rb
      register_service.rb            # create user + send confirmation email
      confirm_email_service.rb       # validate token + mark confirmed
      request_password_reset_service.rb
      reset_password_service.rb      # validate token + update password + revoke tokens
    jwt_service.rb
    application_service.rb
  jobs/
    application_job.rb               # Solid Queue backend
spec/
  factories/
  support/
db/
  schema.rb
  migrate/
```

### Layers and responsibilities

- `app/models/`       → ActiveRecord, validations, scopes, AASM state machines, PaperTrail
- `app/services/`     → business logic via Interactor; never in controllers
- `app/controllers/`  → routing + params + HTTP response only
- `app/policies/`     → Pundit authorization objects
- `app/serializers/`  → jsonapi-serializer response shaping
- `app/jobs/`         → Solid Queue background jobs (no Redis)

### Important architectural decisions

- Authentication always via Bearer token (`Authorization: Bearer <token>`), never session cookies
- Refresh tokens use family rotation — token reuse triggers full family revocation (detect token theft)
- Only the token digest is stored in DB, never the raw token value
- Pundit policies are the single source of authorization truth — no ad-hoc `if current_user.admin?` in controllers
- jsonapi-serializer format for all API responses (envelope: `{ data: { id, type, attributes } }`)
- Solid Queue over Sidekiq — no Redis dependency
- `strong_migrations` enforced — no dangerous migration patterns allowed

---

## Constraints (rules the AI must not break)

- Never modify already-applied migrations in production
- Never store raw token values — always store digests
- All business logic goes through service objects (Interactor), not controllers
- Authorization always goes through Pundit policies, never inline checks
- Never add gems or dependencies without discussing first
- The public API schema is versioned — breaking changes go to `/api/v2/`
- `bundle exec rubocop --autocorrect-all` must pass before committing
- Brakeman must pass with zero warnings before any PR

---

## Stack specifics

**Versions:**
```
Ruby 3.3.10
Rails 8.1.3
PostgreSQL 17
```

**Critical dependencies:**
```
jwt                 # JSON Web Tokens — stateless auth
bcrypt ~> 3.1.7     # password hashing
pundit              # policy-based authorization
pagy                # pagination (default limit: 25, max: 100)
pg_search           # full-text search via PostgreSQL tsearch
interactor          # service objects / business logic
paper_trail         # audit trail / change history
solid_queue         # background jobs on PostgreSQL (no Redis)
rack-attack         # rate limiting
rack-cors           # CORS
jsonapi-serializer  # JSON:API response format
aasm                # state machines
enumerize           # enumerated attributes with I18n
strong_migrations   # prevents unsafe migrations
```

---

## Standards and conventions

Detailed standards live in `.agents/standards/`.
The topic map is in `.agents/standards/index.yml`.

Quick summary:
- **Naming:** `snake_case` everywhere (Ruby conventions)
- **Tests:** RSpec + FactoryBot; all services, models, and controllers require coverage
- **Error handling:** never `rescue Exception`; always rescue specific `StandardError` subclasses; centralized via `ErrorHandler` concern
- **Commits:** Conventional Commits, lowercase imperative (`feat:`, `fix:`, `chore:`)
- **API responses:** JSON:API envelope (`data`, `meta`, `error`) — see `.agents/standards/api-design.md`

---

## Common mistakes

Frequent project-specific errors live in `.agents/common-mistakes/`.
The map is in `.agents/common-mistakes/index.yml`.

---

## GitNexus

This project is indexed by GitNexus for code graph analysis.

```bash
# View API route map
/gitnexus:route_map

# Impact of changing a symbol
/gitnexus:impact symbol=ClassName

# Execution flows related to a concept
/gitnexus:query concept

# Pre-change impact on a route
/gitnexus:api_impact
```

> Use `gitnexus:impact` before refactoring any class or public method.
> Use `gitnexus:api_impact` before modifying an endpoint.

---

## Development process

See full flow in `docs/DEVELOPMENT_FLOW.md`.

Standard flow:
1. `/plan-small` or `/plan-large` → writes `.plans/<slug>/plan.md`
2. Review the plan, approve
3. `/implement-plan-audited mode=auto` → executes with automatic audits
4. `/code-audit-hardcore` → post-implementation cleanup if needed
5. `/cap` → clean commit

---

## Current project state

**Phase:** Boilerplate / Foundation
**Last important decision:** Full auth flow implemented — registration, email confirmation, and password reset with token digest storage
**Work in progress:** branch `add-dev-template` — auth endpoints (register, confirm, password reset) + UserMailer + UserPolicy + UserSerializer

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **saas-rails-psql-base** (352 symbols, 483 relationships, 8 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/saas-rails-psql-base/context` | Codebase overview, check index freshness |
| `gitnexus://repo/saas-rails-psql-base/clusters` | All functional areas |
| `gitnexus://repo/saas-rails-psql-base/processes` | All execution flows |
| `gitnexus://repo/saas-rails-psql-base/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
