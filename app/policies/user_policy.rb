class UserPolicy < ApplicationPolicy
  # A user can only view their own profile.
  def show? = record == user

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(id: user.id)
  end
end
