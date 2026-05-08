# Standards: Rails

Stack-specific conventions for this Rails 8 API boilerplate.
These rules apply to every project derived from `saas-rails-psql-base`.

---

## Controllers

### Inheritance hierarchy

```
ActionController::API
  └── ApplicationController          # thin base, no logic
        └── Api::V1::BaseController  # JWT auth + Pundit + ErrorHandler
              └── YourController     # feature controllers go here
```

**Never** inherit directly from `ApplicationController` for feature endpoints.
Only `SessionsController` (auth endpoints) and special public endpoints skip `BaseController`.

### Responsibilities — what belongs in a controller

```ruby
# ✅ Controller does: routing, params, call one service, render
def create
  result = Users::CreateService.call(user_params)
  render json: UserSerializer.new(result.user).serializable_hash, status: :created
end

# ❌ Never: business logic, DB queries, conditional branching in controllers
def create
  user = User.find_by(email: params[:email])
  return render json: { error: "taken" } if user
  user = User.create!(params.permit(:email, :name))
  UserMailer.welcome(user).deliver_later
  render json: user
end
```

### Pundit — mandatory authorization

`BaseController` enforces `verify_authorized` (non-index) and `verify_policy_scoped` (index).
Every action **must** call `authorize` or `policy_scope` — the after_action will raise if you forget.

```ruby
# Single resource
def show
  @widget = Widget.find(params[:id])
  authorize @widget           # calls WidgetPolicy#show?
  render json: WidgetSerializer.new(@widget).serializable_hash
end

# Collection
def index
  @widgets = policy_scope(Widget)   # calls WidgetPolicy::Scope#resolve
  records, meta = paginate(@widgets)
  render json: WidgetSerializer.new(records).serializable_hash.merge(meta: meta)
end
```

### Pagination

Use the `paginate` helper from `BaseController`. Never hand-roll `limit`/`offset`.

```ruby
records, meta = paginate(policy_scope(Widget), per_page: 25)
render json: WidgetSerializer.new(records).serializable_hash.merge(meta: meta)
```

Default: 25 per page. Max: 100. Query params: `?page=2&per_page=50`.

### Strong parameters

Always define a private `*_params` method. Never `params[:resource].to_h`.

```ruby
private

def widget_params
  params.require(:widget).permit(:name, :status, :description)
end
```

---

## Services

### Pattern: `ApplicationService` with `.call`

All business logic lives in `app/services/`. Services inherit from `ApplicationService`
which exposes `.call` as a class method delegating to `#call`.

```ruby
# app/services/widgets/create_service.rb
module Widgets
  class CreateService < ApplicationService
    Result = Data.define(:widget)

    def initialize(params:, user:)
      @params = params
      @user   = user
    end

    def call
      widget = Widget.create!(@params)
      Result.new(widget: widget)
    end
  end
end

# Usage
result = Widgets::CreateService.call(params: widget_params, user: current_user)
```

### Rules

- One service = one operation. No `CreateOrUpdateService`.
- Return a `Data.define` result object, not a raw AR record.
- Services raise on failure (`create!`, `update!`). Let `ErrorHandler` rescue.
- No HTTP concerns in services (no `render`, no `redirect_to`, no `params`).
- No controller concerns in services (no `current_user` injection from outside unless explicitly passed).
- Namespace under the domain: `Users::`, `Widgets::`, `Auth::`.

### Note on Interactor

The `interactor` gem is in the Gemfile. Prefer `ApplicationService` for new code — both
solve the same problem. If you start using `Interactor::Organizer` for multi-step
orchestration, document the decision. Do not mix both patterns in the same domain.

---

## Models

### What belongs in a model

```ruby
# ✅ OK in models:
# - has_secure_password, associations, validations
# - scopes (named, reusable queries)
# - AASM state machines
# - enumerize attributes
# - PaperTrail: has_paper_trail
# - Class methods that are pure DB queries

# ❌ Never in models:
# - Business logic that spans multiple models
# - Mailer calls, HTTP calls, job enqueues
# - Anything that should be a service
```

### Scopes

Always name scopes explicitly. Never use anonymous lambdas inline in queries.

```ruby
scope :active,    -> { where(status: :active) }
scope :recent,    -> { order(created_at: :desc) }
scope :for_user,  ->(user) { where(user: user) }
```

### Enumerize

```ruby
extend Enumerize
enumerize :status, in: %i[draft active archived], default: :draft, predicates: true, scope: true
```

### AASM state machines

```ruby
include AASM

aasm column: :status do
  state :draft, initial: true
  state :active
  state :archived

  event :activate do
    transitions from: :draft, to: :active
  end
end
```

### PaperTrail

Enable per-model. Do not rely on a global `has_paper_trail` on `ApplicationRecord`.

```ruby
class Widget < ApplicationRecord
  has_paper_trail
end
```

---

## Policies (Pundit)

### Structure

```ruby
# app/policies/widget_policy.rb
class WidgetPolicy < ApplicationPolicy
  def show?    = record.user == user
  def create?  = true
  def update?  = record.user == user
  def destroy? = record.user == user

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(user: user)
  end
end
```

`ApplicationPolicy` denies everything by default (`false`). Override only what you allow.

### Rules

- Never `if current_user.admin?` inline in a controller or service. Put it in the policy.
- Always define `Scope` if the model is listed in any `index` action.
- Return 403, not 404, when a record exists but the user has no access (the `ErrorHandler` handles this via `Pundit::NotAuthorizedError`).

---

## Serializers

### Pattern

```ruby
# app/serializers/widget_serializer.rb
class WidgetSerializer < BaseSerializer
  attributes :name, :status, :created_at

  belongs_to :user
  has_many   :tags
end
```

`BaseSerializer` sets `key_transform :underscore` — all keys are `snake_case` in responses.

### Response envelope

```json
// Single resource
{ "data": { "id": "1", "type": "widget", "attributes": { "name": "..." } } }

// Collection (add meta manually in controller)
{ "data": [...], "meta": { "current_page": 1, "per_page": 25, "total_pages": 4, "total_count": 87 } }
```

Never return raw AR objects. Always go through a serializer.

---

## Routes

```ruby
namespace :api do
  namespace :v1 do
    resources :widgets, only: %i[index show create update destroy] do
      member do
        post :activate   # non-CRUD action as sub-resource
      end
    end
  end
end
```

- Always namespace under `/api/v1/`.
- Use only the actions you implement (`only:`).
- Non-CRUD actions: verb as a member route (`post :activate`), not `POST /widgets/activate`.
- Breaking API changes go to `/api/v2/` — never break v1 consumers.

---

## Background Jobs

Use Solid Queue via Active Job. No Redis required.

```ruby
# app/jobs/send_welcome_email_job.rb
class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end

# Enqueue from a service
SendWelcomeEmailJob.perform_later(user.id)
```

- Always pass IDs, never AR objects — they can go stale in the queue.
- Idempotency: jobs should be safe to retry without side effects.
- Use `queue_as :default` unless you have a strong reason for a custom queue.

---

## Error handling

`ErrorHandler` concern (included in `BaseController`) centralizes all rescue logic:

| Exception | HTTP status |
|-----------|------------|
| `ActiveRecord::RecordNotFound` | 404 |
| `ActiveRecord::RecordInvalid` | 422 |
| `ActionController::ParameterMissing` | 400 |
| `JWT::DecodeError`, `JWT::ExpiredSignature` | 401 |
| `Auth::InvalidCredentialsError` | 401 |
| `Pundit::NotAuthorizedError` | 403 |
| `Auth::EmailNotConfirmedError` | 403 |

**Rules:**
- Never add `rescue_from` in feature controllers — add to `ErrorHandler` concern.
- Services raise exceptions; controllers never rescue inline.
- Never rescue `Exception` — always rescue a specific `StandardError` subclass.
- Never expose stack traces, SQL errors, or internal paths in error responses.

---

## Testing

### Structure

```
spec/
  factories/         # FactoryBot — one file per model
  models/            # model validations, scopes, methods
  requests/          # full request specs (preferred over controller specs)
    api/v1/
      widgets_spec.rb
  support/
    database_cleaner.rb
    request_helpers.rb  # json_response, auth_headers(user)
    vcr.rb
```

### Request specs — the primary test layer

```ruby
RSpec.describe "Api::V1::Widgets", type: :request do
  let(:user)   { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/widgets" do
    it "returns the user's widgets" do
      create_list(:widget, 3, user: user)
      get "/api/v1/widgets", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response[:data].size).to eq(3)
    end
  end
end
```

### Factories

```ruby
FactoryBot.define do
  factory :widget do
    user
    name   { Faker::Commerce.product_name }
    status { :draft }

    trait :active do
      status { :active }
    end
  end
end
```

### Rules

- Every service gets a unit spec (`spec/services/`).
- Every model gets a model spec for validations and scopes.
- Every endpoint gets a request spec — happy path + auth failure + validation failure.
- Use `DatabaseCleaner` — already configured in `spec/support/database_cleaner.rb`.
- Use `timecop` for time-sensitive logic. Use `vcr`/`webmock` for external HTTP.
- Never test implementation details — test behavior through the HTTP layer.

---

## Generators

Configured in `config/initializers/generators.rb`. Running `rails g model` or
`rails g resource` automatically generates:
- RSpec request spec
- FactoryBot factory
- No helper, no views, no assets (API only)

---

## Migrations

`strong_migrations` is enforced. Unsafe patterns raise at boot.

```ruby
# ❌ Unsafe — locks table in production
add_column :widgets, :status, :string, null: false, default: "draft"

# ✅ Safe — add nullable, backfill, then add constraint
add_column :widgets, :status, :string
Widget.update_all(status: "draft")
change_column_null :widgets, :status, false
```

- Never modify a migration that has already been applied in production.
- New columns: nullable first, backfill, then constrain.
- Adding indexes: always `algorithm: :concurrently` on large tables.

---

## Datetime format

All datetimes serialize as ISO 8601 with second precision: `"2024-01-15T09:30:00Z"`.
Configured in `config/initializers/json_encoding.rb`. Do not override per-serializer.

---

## Common patterns — quick reference

```ruby
# Authenticate + authorize in one controller action
def show
  @widget = Widget.find(params[:id])
  authorize @widget
  render json: WidgetSerializer.new(@widget).serializable_hash
end

# Paginated collection with meta
def index
  records, meta = paginate(policy_scope(Widget))
  render json: WidgetSerializer.new(records).serializable_hash.merge(meta: meta)
end

# Service call + render
def create
  result = Widgets::CreateService.call(params: widget_params, user: current_user)
  render json: WidgetSerializer.new(result.widget).serializable_hash, status: :created
end

# Enqueue a job from a service
SendWelcomeEmailJob.perform_later(user.id)

# Full-text search
scope :search_by_name, ->(query) { pg_search_scope :search, against: :name }
```
