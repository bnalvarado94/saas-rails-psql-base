# Purpose: Base serializer demonstrating jsonapi-serializer usage pattern.
# All serializers should inherit from this class for consistent behavior.
#
# Example usage:
#   class UserSerializer < BaseSerializer
#     attributes :email, :name, :created_at
#     has_many :posts
#   end
#
#   UserSerializer.new(user).serializable_hash.to_json

class BaseSerializer
  include JSONAPI::Serializer

  # Use underscored keys for consistency with Rails conventions
  set_key_transform :underscore
end
