class UserSerializer < BaseSerializer
  attributes :email, :first_name, :last_name, :confirmed_at

  def self.serialize_user(user)
    {
      id:           user.id,
      email:        user.email,
      first_name:   user.first_name,
      last_name:    user.last_name,
      confirmed_at: user.confirmed_at
    }
  end
end
