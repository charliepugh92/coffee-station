class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  # On success devise-jwt has already put the token in the Authorization header;
  # the body just carries a minimal user (the SPA refetches via the `me` query).
  def respond_with(resource, _opts = {})
    render json: { data: { user: UserSerializer.new(resource).as_json } }, status: :ok
  end

  def respond_to_on_destroy(*_args, **_kwargs)
    render json: { message: "Signed out." }, status: :ok
  end
end
