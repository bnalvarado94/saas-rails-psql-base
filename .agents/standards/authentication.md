# Standards: Authentication

Auth flows implemented in this boilerplate. All custom errors are rescued centrally
in `ErrorHandler` — never rescue them inline in controllers.

---

## Endpoints

| Method | Path | Controller action | Auth required |
|--------|------|-------------------|---------------|
| POST | `/api/v1/auth/register` | `registrations#create` | No |
| POST | `/api/v1/auth/login` | `sessions#create` | No |
| POST | `/api/v1/auth/refresh` | `sessions#refresh` | No (refresh token) |
| DELETE | `/api/v1/auth/logout` | `sessions#destroy` | No (refresh token) |
| POST | `/api/v1/auth/confirm` | `confirmations#create` | No |
| POST | `/api/v1/auth/password/reset` | `passwords#create` | No |
| PATCH | `/api/v1/auth/password/reset/confirm` | `passwords#confirm` | No |

Auth endpoints **do not inherit** from `BaseController` — they skip JWT enforcement and
Pundit verification because they are public by design.

---

## Token storage rules

- **JWT access token:** stateless, short-lived, never stored in DB. Payload: `{ user_id: }`.
- **Refresh token:** only the `SHA256` digest stored (`refresh_tokens.token_digest`). Raw value returned once to the client, then discarded.
- **Confirmation token:** only `confirmation_token_digest` stored. Raw sent via email.
- **Password reset token:** only `reset_password_token_digest` stored. Raw sent via email.

**Never** store or log a raw token value. Always `Digest::SHA256.hexdigest(raw)` before any DB write.

---

## Registration flow

```
POST /api/v1/auth/register
  → Auth::RegisterService
      → User.create!
      → user.generate_confirmation_token!   # stores digest, returns raw
      → UserMailer.confirmation_email.deliver_later
      → JwtService.encode + RefreshToken.generate_for
  ← 201 { access_token, refresh_token, user }
```

- Issues tokens immediately — user can use the API before confirming email.
- `EmailNotConfirmedError` is raised by `LoginService` if user tries to log in without confirming.

---

## Email confirmation flow

```
POST /api/v1/auth/confirm  { token: "<raw>" }
  → Auth::ConfirmEmailService
      → SHA256(token) → User.find_by(confirmation_token_digest:)
      → raise InvalidTokenError if not found
      → raise ExpiredTokenError if confirmation_expired?
      → user.update!(confirmed_at:, confirmation_token_digest: nil)
  ← 200 { user }
```

Token expiry is checked via `user.confirmation_expired?` — defined on the model.
After confirmation, `confirmation_token_digest` and `confirmation_sent_at` are cleared.

---

## Password reset flow

```
POST /api/v1/auth/password/reset  { email: }
  → Auth::RequestPasswordResetService
      → User.find_by(email:) — silent no-op if not found (no user enumeration)
      → user.generate_reset_password_token!
      → UserMailer.reset_password_email.deliver_later
  ← 200 (always, even if email not found)

PATCH /api/v1/auth/password/reset/confirm  { token:, password: }
  → Auth::ResetPasswordService
      → SHA256(token) → User.find_by(reset_password_token_digest:)
      → raise InvalidTokenError / ExpiredTokenError
      → user.update!(password:, reset_password_token_digest: nil)
      → user.refresh_tokens.update_all(revoked_at: Time.current)  # invalidate all sessions
  ← 200 { user }
```

Password reset **revokes all refresh tokens** for the user — forces re-login on all devices.

---

## Custom errors and HTTP mapping

| Error class | Raised by | HTTP |
|-------------|-----------|------|
| `Auth::InvalidCredentialsError` | `LoginService` | 401 |
| `Auth::EmailNotConfirmedError` | `LoginService` | 403 |
| `Auth::ConfirmEmailService::InvalidTokenError` | `ConfirmEmailService` | — (rescue in controller) |
| `Auth::ConfirmEmailService::ExpiredTokenError` | `ConfirmEmailService` | — (rescue in controller) |
| `Auth::ResetPasswordService::InvalidTokenError` | `ResetPasswordService` | — (rescue in controller) |
| `Auth::ResetPasswordService::ExpiredTokenError` | `ResetPasswordService` | — (rescue in controller) |

`InvalidCredentialsError` and `EmailNotConfirmedError` are global and rescued in `ErrorHandler`.
Token-specific errors (`InvalidTokenError`, `ExpiredTokenError`) are inner classes — rescue them
in the auth controllers that call those services.

---

## Security rules

- Never reveal whether an email exists in the password-reset request response (always 200).
- Confirmation and reset tokens are one-time-use: cleared from DB on success.
- Token expiry windows are defined on the `User` model — do not hardcode durations in services.
- After a successful password reset, all refresh token families are revoked.
- Rate limit `/auth/login`, `/auth/register`, and `/auth/password/reset` via Rack::Attack.
