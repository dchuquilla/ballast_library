# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Users API", type: :request do
  path "/users/sign_in" do
    post "Sign in a user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      let!(:existing_user) { create(:user, password: "password") }

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
            },
            required: ["email", "password"],
          },
        },
        redquired: ["user"],
      }

      response(200, "user signed in") do
        let(:params) { { user: { email: existing_user.email, password: "password" }, format: :json } }
        run_test!
      end

      response(401, "invalid credentials") do
        let(:params) { { user: { email: existing_user.email, password: "wrong_password" }, format: :json } }
        run_test!
      end
    end
  end

  path "/users/sign_out" do
    delete "Sign out a user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      response(200, "user signed out") do
        run_test!
      end
    end
  end
end
