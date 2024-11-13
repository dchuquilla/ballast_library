class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    super do |user|
      if user.persisted?
        token = generate_token_for(user) # Ensure this method generates a valid token
        response.headers["Authorization"] = "Bearer #{token}"
      else
        Rails.logger.info "User not persisted: #{user.errors.full_messages.join(", ")}"
      end
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { message: "Logged in successfully." }, status: :ok
    else
      render json: { message: "Invalid login credentials." }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    render json: { message: "Logged out successfully." }, status: :ok
  end

  def generate_token_for(user)
    # Implement token generation logic here
    # For example, using JWT:
    JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.secrets.secret_key_base)
  end
end
