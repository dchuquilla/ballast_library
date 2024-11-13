# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"

RSpec.describe "Books API", type: :request do
  let(:user) { create(:user) }
  let(:authorization) { get_token_bearer(user) }

  path "/books" do
    get "List all books" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      let(:all_books) { create_list(:book, 50) }

      response "200", "books listed" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   author: { type: :string },
                   genre: { type: :string },
                   isbn: { type: :string },
                   total_copies: { type: :integer },
                 },
                 required: %w[id title author genre isbn total_copies],
               }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns all books" do
          body = JSON.parse(response.body)
          target_book = Book.last

          expect(response).to have_http_status(:ok)
          expect(target_book.title).to eq(body.find { |book| book["id"] == target_book.id }["title"])
          expect(body.size).to eq(Book.count)
        end
      end
    end
  end
end
