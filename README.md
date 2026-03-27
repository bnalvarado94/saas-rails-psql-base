# 🚀 SaaS Rails Boilerplate

A production-ready API boilerplate built with Ruby on Rails 8, PostgreSQL, and Docker.
Designed for multi-tenant SaaS applications with TDD from the ground up.

## 🛠️ Tech Stack

- **Ruby** 3.3.4
- **Rails** 8.1.3 (API mode)
- **PostgreSQL** 16
- **Docker** + Docker Compose
- **RSpec** + FactoryBot + Faker
- **JWT** + BCrypt (Authentication)
- **JSONAPI Serializer**

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

## 📁 Project Structure

```
app/
├── controllers/
│   └── api/
│       └── v1/          # Versioned API controllers
├── models/              # ActiveRecord models
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

## 🐳 Docker Commands

```bash
# Start all services
docker compose up

# Run Rails console
docker compose exec web rails console

# Run a migration
docker compose exec web rails db:migrate

# Open a bash shell
docker compose exec web bash

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

```bash
# Watch mode (run tests on file change)
docker compose run test bundle exec rspec --watch
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

## 👤 Author

**Brian Alvarado** — Senior Full-Stack Engineer

- GitHub: [@bnalvarado94](https://github.com/bnalvarado94)
- Email: bnalvarado94@gmail.com
