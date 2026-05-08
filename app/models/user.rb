class User < ApplicationRecord
  TOKEN_BYTES = 32
  CONFIRMATION_EXPIRY = 24.hours
  RESET_PASSWORD_EXPIRY = 1.hour

  has_secure_password

  has_many :refresh_tokens, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, allow_nil: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  # Generates a confirmation token, stores only the digest, returns the raw token.
  def generate_confirmation_token!
    raw = SecureRandom.hex(TOKEN_BYTES)
    update!(
      confirmation_token_digest: Digest::SHA256.hexdigest(raw),
      confirmation_sent_at: Time.current
    )
    raw
  end

  def confirm!(raw_token)
    return false if confirmation_expired?
    return false unless Digest::SHA256.hexdigest(raw_token) == confirmation_token_digest

    update!(
      confirmed_at: Time.current,
      confirmation_token_digest: nil,
      confirmation_sent_at: nil
    )
    true
  end

  def confirmation_expired?
    confirmation_sent_at.nil? || confirmation_sent_at < CONFIRMATION_EXPIRY.ago
  end

  def generate_reset_password_token!
    raw = SecureRandom.hex(TOKEN_BYTES)
    update!(
      reset_password_token_digest: Digest::SHA256.hexdigest(raw),
      reset_password_sent_at: Time.current
    )
    raw
  end

  def reset_password_expired?
    reset_password_sent_at.nil? || reset_password_sent_at < RESET_PASSWORD_EXPIRY.ago
  end
end
