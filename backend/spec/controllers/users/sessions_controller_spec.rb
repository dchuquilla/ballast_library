require "rails_helper"

RSpec.describe Users::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "responds with a success on login" do
        sign_in user
        post :create, params: { user: { email: user.email, password: user.password } }, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Logged in successfully.")
      end

      it "includes a bearer token in the response" do
        sign_in user
        post :create, params: { user: { email: user.email, password: user.password } }, format: :json
        expect(response).to have_http_status(:ok)
        expect(response.headers["Authorization"]).to match(/^Bearer /)
      end
    end
  end

  describe "DELETE #destroy" do
    it "responds with a success on logout" do
      sign_in user
      delete :destroy, format: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Logged out successfully.")
    end

    it "removes the bearer token from the response" do
      sign_in user
      delete :destroy, format: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to be_nil
    end
  end
end
