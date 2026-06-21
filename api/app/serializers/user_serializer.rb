# Minimal JSON payload for the Devise REST endpoints. The SPA only needs enough
# to confirm who signed in; full profile data comes from the `me` GraphQL query.
class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: @user.id,
      email: @user.email,
      display_name: @user.display_name
    }
  end
end
