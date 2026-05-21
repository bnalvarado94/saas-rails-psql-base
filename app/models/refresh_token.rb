class RefreshToken < ApplicationRecord
  EXPIRY = 30.days
  TOKEN_BYTES = 32

  belongs_to :user

  validates :token_digest, :family_id, :expires_at, presence: true

  scope :active, -> { where(used_at: nil, revoked_at: nil).where("expires_at > ?", Time.current) }
  scope :for_family, ->(family_id) { where(family_id: family_id) }

  # Generates a new refresh token for the given user, returns [record, raw_token].
  # The raw_token is returned only once and never stored.
  def self.generate_for(user:, request: nil)
    raw = SecureRandom.hex(TOKEN_BYTES)
    record = create!(
      user: user,
      token_digest: digest(raw),
      family_id: SecureRandom.uuid,
      expires_at: EXPIRY.from_now,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
    [ record, raw ]
  end

  # Finds a refresh token by raw value. Returns nil if not found.
  def self.find_by_raw(raw)
    find_by(token_digest: digest(raw))
  end

  def self.digest(raw)
    Digest::SHA256.hexdigest(raw)
  end

  def active?
    used_at.nil? && revoked_at.nil? && expires_at > Time.current
  end

  # Marks this token as used and creates a new one in the same family.
  # Returns [new_record, raw_token].
  def rotate!(request: nil)
    touch(:used_at)

    raw = SecureRandom.hex(TOKEN_BYTES)
    new_record = self.class.create!(
      user: user,
      token_digest: self.class.digest(raw),
      family_id: family_id,
      expires_at: EXPIRY.from_now,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
    [ new_record, raw ]
  end

  # Revokes all tokens in the same family — called on theft detection.
  # Scoped to user_id as a defense-in-depth measure against family_id collisions.
  def revoke_family!
    self.class.where(family_id: family_id, user_id: user_id).update_all(revoked_at: Time.current)
  end
end
