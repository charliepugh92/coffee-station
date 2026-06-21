class ApplicationController < ActionController::API
  def root
    render json: { message: "Davey's Coffee API", version: "0.1.0" }, status: :ok
  end
end
