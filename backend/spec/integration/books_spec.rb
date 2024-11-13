# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"
require "faker"

RSpec.describe "Books API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user) }
  let(:authorization) { get_token_bearer(user) }
  let(:all_books) { create_list(:book, 50) }

  path "/v1/member/books" do
    get "Member List all books" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

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

    post "Member can't Create book" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      response "404", "Cant't book created" do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found route" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["error"]).to eq("Not Found")
        end
      end
    end
  end

  path "/v1/member/books/{id}" do
    get "Member see a single book" do
      tags "Books"
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

    patch "Member can't Update book" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response("404", "Can't update a book") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { all_books.first.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found route" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["error"]).to eq("Not Found")
        end
      end
    end

    delete "Member can't Delete book" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response("404", "Can't delete a book") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { all_books.first.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found route" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["error"]).to eq("Not Found")
        end
      end
    end
  end
end
