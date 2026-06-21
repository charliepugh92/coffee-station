class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  private

  # POST (request reset) is paranoid — always reports success so the endpoint
  # can't be used to probe which emails are registered. PUT (perform reset)
  # surfaces validation errors (e.g. weak/blank password, bad token).
  def respond_with(resource, _opts = {})
    # On a successful reset *request*, Devise passes an empty Hash (no resource);
    # on a reset *perform* it passes the User, which may carry validation errors.
    if !resource.is_a?(User) || resource.errors.empty?
      render json: { message: "If that email exists, reset instructions were sent." }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
    end
  end
end
