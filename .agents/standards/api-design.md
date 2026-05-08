# Standards: API Design

---

## General principles

- REST over RPC for resources. RPC only for actions that are not clear CRUD.
- Versioned from day 1: `/api/v1/`. Breaking changes go to `/api/v2/`.
- Consistent responses: always the same envelope.
- Informative errors without exposing internals.

---

## Endpoints

### Naming
```
GET    /api/v1/resources          → list
GET    /api/v1/resources/:id      → get one
POST   /api/v1/resources          → create
PATCH  /api/v1/resources/:id      → partial update
DELETE /api/v1/resources/:id      → delete

# Non-CRUD actions: verb as sub-resource
POST   /api/v1/resources/:id/activate
POST   /api/v1/analysis-jobs/:id/cancel
```

### DON'T
```
POST /api/v1/createUser           ❌ verb in URL
GET  /api/v1/getActiveUsers       ❌
POST /api/v1/user/do-action       ❌ imprecise
```

---

## Responses

### Success
```json
// Single resource
{
  "data": {
    "id": "uuid",
    "type": "analysis_job",
    "attributes": { ... }
  }
}

// Collection
{
  "data": [ ... ],
  "meta": {
    "total": 142,
    "page": 1,
    "per_page": 25
  }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is invalid",
    "details": {
      "email": ["is invalid", "is already taken"]
    }
  }
}
```

---

## HTTP status codes

| Situation | Code |
|-----------|------|
| OK | 200 |
| Created | 201 |
| No content (DELETE) | 204 |
| Bad request / validation | 422 |
| Unauthenticated | 401 |
| Forbidden | 403 |
| Not found | 404 |
| Conflict (already exists) | 409 |
| Rate limit | 429 |
| Server error | 500 |

**Rule:** Never 200 with `{ success: false }` in the body. The status code is the source of truth.

---

## Authentication

```
# Bearer token in header, always
Authorization: Bearer <token>

# If resource is multi-tenant, include org context
X-Organization-Id: <org_uuid>
```

---

## Pagination

```
# Standard query params
GET /api/v1/resources?page=2&per_page=25

# Response includes meta
{
  "meta": {
    "total": 142,
    "page": 2,
    "per_page": 25,
    "total_pages": 6
  }
}
```

Default: `per_page=25`, max: `per_page=100` (enforced by Pagy).

---

## Security

- Never return data from other tenants (always scope to org/user)
- Never include sensitive information in error responses
- Rate limiting on all public endpoints
- Input validation before any processing
- Never trust client-provided IDs without verifying ownership
