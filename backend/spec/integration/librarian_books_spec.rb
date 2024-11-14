# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"
require "faker"

RSpec.describe "Librarian Books API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user, :librarian) }
  let(:authorization) { get_token_bearer(user) }
  let(:all_books) { create_list(:book, 50) }
  let(:changed_isbn) { "isbn-#{SecureRandom.alphanumeric(6)}" }

  path "/v1/librarian/books" do
    get "Librarian list all books" do
      tags "Librarian Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      response(200, "books listed") do
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
          all_books
          submit_request(example.metadata)
        end

        it "returns all books" do
          body = JSON.parse(response.body)
          target_book = all_books.last

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

      response(201, "book created") do
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

      response(200, "book found") do
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

      response(404, "book not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found route" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end

    patch "Librarian can Update book" do
      tags "Librarian Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true
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

      response(200, "book updated") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 author: { type: :string },
                 genre: { type: :string },
                 isbn: { type: :string },
                 total_copies: { type: :integer },
               }
        let(:id) { all_books.first.id }

        let(:params) do
          {
            book: {
              title: "Changed Title",
              author: Faker::Book.author,
              genre: Faker::Book.genre,
              isbn: changed_isbn,
            },
          }
        end

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the updated book" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect("Changed Title").to eq(body["title"])
          expect(changed_isbn).to eq(body["isbn"])
        end
      end

      response(422, "book not updated") do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } },
               }

        let(:id) { all_books.first.id }

        let(:params) do
          {
            book: {
              title: "Changed Title",
              author: Faker::Book.author,
              genre: Faker::Book.genre,
              isbn: all_books.last.isbn,
            },
          }
        end

        before do |example|
          all_books
          submit_request(example.metadata)
        end

        it "returns the updated book" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(body["errors"]).to include("Isbn has already been taken")
        end
      end

      response(404, "book not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }

        let(:params) do
          {
            book: {
              title: "Changed Title",
              author: Faker::Book.author,
              genre: Faker::Book.genre,
              isbn: all_books.first.isbn,
            },
          }
        end

        before do |example|
          all_books
          submit_request(example.metadata)
        end

        it "returns the updated book" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end

    delete "Librarian can delete book" do
      tags "Librarian Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "book deleted") do
        let(:id) { all_books.first.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns no content" do
          expect(response).to have_http_status(:no_content)
          expect(Book.find_by(id: all_books.first.id)).to be_nil
        end
      end

      response(404, "book not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found route" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end
  end

  path "/v1/librarian/books/search" do
    get "Librarian Search books" do
      tags "Librarian Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :query, in: :query, type: :string, required: true

      response(200, "books listed") do
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

        let(:query) { all_books.first.isbn }

        before do |example|
          all_books
          submit_request(example.metadata)
        end

        it "returns found books" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body.size).to eq(1)
          expect(Book.first.isbn).to eq(body.first["isbn"])
        end
      end
    end
  end
end
