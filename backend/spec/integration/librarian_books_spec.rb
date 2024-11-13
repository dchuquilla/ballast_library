# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"
require "faker"

RSpec.describe "Librarian Books API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user, :librarian) }
  let(:authorization) { get_token_bearer(user) }

  path "/v1/librarian/books" do
    get "Librarian list all books" do
      tags "Librarian Books"
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

    post "Librarian can create book" do
      tags "Librarian Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            type: :object,
            properties: {
              title: { type: :string },
              author: { type: :string },
              genre: { type: :string },
              isbn: { type: :string },
            },
            required: %w[title author genre isbn],
          },
        },
        required: %w[book],
      }

      response "201", "book created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 author: { type: :string },
                 genre: { type: :string },
                 isbn: { type: :string },
                 total_copies: { type: :integer },
               }

        let(:params) do
          {
            book: {
              title: Faker::Book.title,
              author: Faker::Book.author,
              genre: Faker::Book.genre,
              isbn: Faker::Code.isbn,
            },
          }
        end

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the created book" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:created)
          expect(Book.last.title).to eq(body["title"])
        end
      end
    end
  end

  path "/v1/librarian/books/{id}" do
    get "Librarian see a single book" do
      tags "Librarian Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      let(:book) { create(:book) }

      response "200", "book found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 author: { type: :string },
                 genre: { type: :string },
                 isbn: { type: :string },
                 total_copies: { type: :integer },
               }

        let(:id) { book.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the book" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(book.title).to eq(body["title"])
        end
      end
    end
  end
end
