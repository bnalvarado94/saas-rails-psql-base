# Standards: Security

---

## Authentication

- Tokens: store only the digest, never the raw value
- Sessions: SameSite=Lax for cross-origin, Secure in production, always HttpOnly
- JWT: validate `exp`, `iss`, `aud`. Never `alg: none`.
- API keys: rotation available, immediate revocation, usage logs
- Passwords: bcrypt with cost >= 12

---

## Authorization

```
# Always verify in this order:
1. Is the user authenticated? (401 if not)
2. Do they have the role/permission? (403 if not)
3. Do they own the resource? (403 if not — never 404, do not reveal existence)
```

- Multi-tenant: **always** scope queries to the authenticated user's tenant
- RBAC: roles are checked at the authorization layer, not ad-hoc in controllers
- Never return 404 when the resource exists but the user lacks access (use 403)
- Authorization always goes through Pundit policies — no inline `if current_user.admin?` in controllers

---

## Input validation

```
# Required pipeline for any external input:
1. Sanitize (strip, normalize encoding)
2. Validate type and format
3. Validate length/range
4. Validate business permissions
```

- SQL: always use parameterized queries, never string interpolation
- HTML: escape output, never `innerHTML` with user data
- File uploads: validate MIME type with magic bytes (not just extension), size limit
- LLM prompts: sanitize input before including in prompts (prompt injection)

---

## Secrets and configuration

```
# Storage hierarchy:
1. Secrets manager (production): AWS Secrets Manager, Vault, etc.
2. Environment variables (staging): uncommitted .env
3. Encrypted credentials (Rails): only if the project already uses them

# NEVER:
- Hardcode secrets in code
- Commit .env with real values
- Log tokens, passwords, API keys
```

---

## Sensitive data

- PII (emails, names, IPs): store only what is necessary, defined retention
- Payments: never store card data, use Stripe/processor tokens
- Logs: mask tokens, passwords, card data before logging
- Errors: do not expose stack traces, SQL errors, or internal paths in production

---

## Prohibited patterns

```ruby
# ❌ SQL injection
User.where("email = '#{params[:email]}'")
# ✅
User.where(email: params[:email])

# ❌ Mass assignment without filter
User.create(params[:user].to_h)
# ✅
User.create(params.require(:user).permit(:name, :email))

# ❌ Trust client Content-Type for file uploads
# ✅ Read magic bytes from the file

# ❌ Expose sequential IDs in URLs (enumeration attack)
# ✅ UUIDs or hashed IDs

# ❌ Cache without considering user context
# ✅ Cache keys that include the user/org id

# ❌ rescue Exception
# ✅ rescue specific StandardError subclasses
```

---

## Refresh token security

- Family rotation: each refresh generates a new token and invalidates the old one
- Token reuse detection: reusing an already-used token revokes the entire family
- Store only `token_digest` in DB — never the raw token
- Track `ip_address`, `user_agent`, `used_at`, `expires_at`, `revoked_at` per token

---

## Rate limiting

- All authentication endpoints: strict rate limit (5-10 req/min per IP)
- Public API endpoints: rate limit per API key
- Upload/processing endpoints: rate limit per user/org
- Response with 429 + `Retry-After` header

---

## Security HTTP headers

```
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

---

## Pre-deploy checklist

- [ ] No secrets in code or git history
- [ ] Rate limiting configured on sensitive endpoints
- [ ] HTTPS enforced in production
- [ ] Security headers configured
- [ ] Inputs validated and sanitized
- [ ] Logs do not contain sensitive data
- [ ] Dependencies updated (no known CVEs) — run `bundler-audit`
- [ ] Brakeman passes with zero warnings
