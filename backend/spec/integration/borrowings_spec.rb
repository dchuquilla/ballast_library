# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"
require "faker"

RSpec.describe "Borrowings API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user) }
  let(:other_member) { create(:user) }
  let(:book_copies) { create_list(:book_copy, 5) }
  let(:more_book_copies) { create_list(:book_copy, 5) }
  let(:borrowings) { book_copies.map { |copy| BorrowBookService.new(user, { book_copy_id: copy.id }).call[:borrowing] } }
  let(:other_borrowings) { more_book_copies.map { |copy| BorrowBookService.new(other_member, { book_copy_id: copy.id }).call[:borrowing] } }
  let(:authorization) { get_token_bearer(user) }

  path "/v1/member/borrowings" do
    get "Member List all borrowings" do
      tags "Borrowings"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      response(200, "borrowings listed") do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   book_copy_id: { type: :integer },
                   user_id: { type: :integer },
                   borrowed_at: { type: :string },
                   due_date: { type: :string },
                   returned_at: { type: :string },
                 },
                 required: %w[id book_copy_id user_id borrowed_at due_date returned_at],
               }

        before do |example|
          borrowings
          submit_request(example.metadata)
        end

        it "returns all borrowings" do
          body = JSON.parse(response.body)
          target_borrowing = Borrowing.last

          expect(response).to have_http_status(:ok)
          expect(target_borrowing.user_id).to eq(user.id)
          expect(target_borrowing.book_copy_id).to eq(body.find { |borrowing| borrowing["id"] == target_borrowing.id }["book_copy_id"])
          expect(body.size).to eq(Borrowing.where(user_id: user.id).count)

          # Other member borrowings should not be included
          expect(body.find { |borrowing| borrowing["user_id"] == other_member.id }).to be_nil
        end
      end
    end
  end

  path "/v1/member/borrowings/{id}" do
    get "Member see its borrowing" do
      tags "Borrowings"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response(200, "borrowing shown") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 book_copy_id: { type: :integer },
                 user_id: { type: :integer },
                 borrowed_at: { type: :string },
                 due_date: { type: :string },
                 returned_at: { type: :string },
               },
               required: %w[id book_copy_id user_id borrowed_at due_date returned_at]

        let(:id) { borrowings.last.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns borrowing" do
          body = JSON.parse(response.body)
          target_borrowing = Borrowing.last

          expect(response).to have_http_status(:ok)
          expect(target_borrowing.user_id).to eq(user.id)
          expect(target_borrowing.book_copy_id).to eq(body["book_copy_id"])
        end
      end

      response(404, "borrowing not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { other_borrowings.last.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["error"]).to eq("Not Found")
        end
      end
    end
  end

  path "/v1/member/borrowings/borrow" do
    post "Member borrow a book" do
      tags "Borrowings"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          borrowing: {
            type: :object,
            properties: {
              book_copy_id: { type: :integer },
            },
            required: %w[book_copy_id],
          },
        },
      }

      response(201, "Book borrowed") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 book_copy_id: { type: :integer },
                 user_id: { type: :integer },
                 borrowed_at: { type: :string },
                 due_date: { type: :string },
                 returned_at: { type: :string },
               },
               required: %w[id book_copy_id user_id borrowed_at due_date returned_at]

        let(:params) { { borrowing: { book_copy_id: more_book_copies.last.id } } }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns borrowing" do
          body = JSON.parse(response.body)
          target_borrowing = Borrowing.last

          expect(response).to have_http_status(:created)
          expect(target_borrowing.user_id).to eq(user.id)
          expect(target_borrowing.book_copy_id).to eq(body["book_copy_id"])
          expect(BookCopy.find(body["book_copy_id"]).status).to eq("borrowed")
        end
      end

      response(422, "A borrowed copy") do
        schema type: :object,
               properties: {
                 errors: { type: :array },
               }

        let(:params) { { borrowing: { book_copy_id: other_borrowings.last.book_copy_id } } }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns errors" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(body["errors"]).to include("Book copy is already borrowed")
        end
      end
    end
  end
end
