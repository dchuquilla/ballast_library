# frozen_string_literal: true

module Helpers
  module Authentication
    # returns a token bearer
    def get_token_bearer(user)
      headers = { "Accept" => "application/json", "Content-Type" => "application/json" }
      auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, user)
      auth_headers["Authorization"]
    end
  end
end
