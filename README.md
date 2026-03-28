# 🚀 SaaS Rails Boilerplate

A production-ready API boilerplate built with Ruby on Rails 8, PostgreSQL 17, and Docker.
Designed for multi-tenant SaaS applications with TDD from the ground up.

## 🛠️ Tech Stack

- **Ruby** 3.3.10
- **Rails** 8.1.3 (API mode)
- **PostgreSQL** 17
- **Docker** + Docker Compose
- **Solid Queue** (background jobs — Rails 8 native, no Redis required)
- **Strong Migrations** (safe migrations in production)
- **RSpec** + FactoryBot + Faker
- **JWT** + BCrypt (Authentication)
- **JSONAPI Serializer**
- **Brakeman** (security scanning)
- **RuboCop** (code style)

---

## ⚙️ Requirements

- Docker Desktop
- Git

> No local Ruby or PostgreSQL installation required — everything runs in Docker.

---

## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone git@github.com:bnalvarado94/saas-rails-psql-base.git
cd saas-rails-psql-base
```

### 2. Set up environment variables

```bash
cp .env.example .env
```

Generate a secret key and add it to `.env`:

```bash
docker compose run web rails secret
```

`.env` example:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=saas_boilerplate_development
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_here
```

### 3. Build and start the containers

```bash
docker compose up --build
```

### 4. Create and migrate the database

```bash
docker compose exec web rails db:create db:migrate
```

### 5. Verify it's running

Visit: [http://localhost:3000](http://localhost:3000)

---

## 🧪 Running the Test Suite

```bash
# Run all specs
docker compose run test

# Run a specific file
docker compose run test bundle exec rspec spec/models/user_spec.rb

# Run with documentation format
docker compose run test bundle exec rspec --format documentation
```

---

## ⚙️ Background Jobs

This boilerplate uses **Solid Queue** — Rails 8's native job backend powered by PostgreSQL. No Redis required.

```bash
# Jobs run automatically with the web server in development
# To run manually:
docker compose exec web bin/jobs
```

---

## 📁 Project Structure

```
app/
├── controllers/
│   └── api/
│       └── v1/          # Versioned API controllers
├── models/              # ActiveRecord models
├── jobs/                # Solid Queue background jobs
├── services/            # Service Objects (business logic)
└── serializers/         # JSONAPI serializers

spec/
├── factories/           # FactoryBot factories
├── models/              # Model specs
├── requests/            # Request/integration specs
└── services/            # Service Object specs
```

---

## 🔑 Authentication

JWT-based authentication via `BCrypt` password hashing.

```
POST /api/v1/auth/login     # Returns JWT token
POST /api/v1/auth/register  # Creates new user
```

Include the token in subsequent requests:

```
Authorization: Bearer <token>
```

---

## 🔒 Security

**Brakeman** runs on every push via CI to catch common Rails security vulnerabilities.

```bash
bin/brakeman --no-pager
```

**Strong Migrations** prevents dangerous migrations that could cause downtime in production.

---

## 🎨 Code Style

**RuboCop** enforces consistent code style across the project.

```bash
# Check
bin/rubocop

# Auto-fix
bin/rubocop -a
```

---

## 🐳 Docker Commands

```bash
# Start all services
docker compose up

# Run Rails console
docker compose exec web rails console

# Run a migration
docker compose exec web rails db:migrate

# Open a shell
docker compose exec web sh

# Stop all containers
docker compose down

# Rebuild from scratch
docker compose down
docker compose build --no-cache
docker compose up
```

---

## 🌱 Development Workflow (TDD)

This boilerplate follows strict Test-Driven Development:

```
🔴 Red    → Write a failing spec first
🟢 Green  → Write the minimum code to make it pass
🔵 Refactor → Clean up without breaking tests
```

---

## 📦 Using This as a Base for New Projects

```bash
# Clone and rename
git clone git@github.com:bnalvarado94/saas-rails-psql-base.git my-new-project
cd my-new-project

# Reset git history
rm -rf .git
git init
git add .
git commit -m "Initial commit from boilerplate"
```

---

## 🔄 CI/CD Pipeline

Every push to `main` and pull request runs the following automated checks via GitHub Actions:

### Jobs

| Job         | Tool     | Purpose                                            |
| ----------- | -------- | -------------------------------------------------- |
| `scan_ruby` | Brakeman | Static analysis for Rails security vulnerabilities |
| `lint`      | RuboCop  | Code style and consistency enforcement             |
| `test`      | RSpec    | Full test suite against PostgreSQL 17              |

### Flow

```
scan_ruby ──┐
            ├──► test
lint ───────┘
```

Tests only run if security scan and lint pass first.

### Running checks locally

```bash
# Security scan
bin/brakeman --no-pager

# Lint
bin/rubocop

# Tests
docker compose run test
```

---

## 👤 Author

**Brian Alvarado** — Senior Full-Stack Engineer

- GitHub: [@bnalvarado94](https://github.com/bnalvarado94)
- Email: bnalvarado94@gmail.com
