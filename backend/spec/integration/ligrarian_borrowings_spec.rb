# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"
require "faker"

RSpec.describe "Borrowings API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user, :librarian) }
  let(:member_user) { create(:user) }
  let(:book_copies) { create_list(:book_copy, 5) }
  let(:borrowings) { book_copies.map { |copy| BorrowBookService.new(member_user, { book_copy_id: copy.id }).call[:borrowing] } }
  let(:authorization) { get_token_bearer(user) }
  let(:update_copy) { create(:book_copy) }
  let(:update_user) { create(:user) }

  path "/v1/librarian/borrowings" do
    get "Librarian List all borrowings" do
      tags "Librarian Borrowings"
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

          expect(response).to have_http_status(:ok)
          # Include member_user borrowings in the list
          expect(body.find { |borrowing| borrowing["user_id"] == member_user.id }).to be_truthy
        end
      end
    end
  end

  path "/v1/librarian/borrowings/{id}" do
    get "Librarian see one borrowing" do
      tags "Librarian Borrowings"
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
          target_borrowing = borrowings.last

          expect(response).to have_http_status(:ok)
          expect(target_borrowing.user_id).to eq(member_user.id)
          expect(target_borrowing.book_copy_id).to eq(body["book_copy_id"])
        end
      end

      response(404, "borrowing not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end

    put "Librarian update borrowing" do
      tags "Librarian Borrowings"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          borrowing: {
            type: :object,
            properties: {
              book_copy_id: { type: :integer },
              user_id: { type: :integer },
              borrowed_at: { type: :string },
              due_date: { type: :string },
              returned_at: { type: :string },
            },
            required: %w[book_copy_id user_id borrowed_at due_date returned_at],
          },
        },
      }

      response(200, "borrowing updated") do
        schema type: :object,
               properties: {
                 book_copy_id: { type: :integer },
                 user_id: { type: :integer },
                 borrowed_at: { type: :string },
                 due_date: { type: :string },
                 returned_at: { type: :string },
               },
               required: %w[book_copy_id user_id borrowed_at due_date returned_at]

        let(:id) { borrowings.last.id }
        let(:params) {
          {
            borrowing: {
              book_copy_id: update_copy.id,
              user_id: update_user.id,
              borrowed_at: Time.zone.now,
              due_date: Time.zone.now + 3.week,
              returned_at: nil,
            },
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns borrowing" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body["user_id"]).to eq(update_user.id)
          expect(body["book_copy_id"]).to eq(update_copy.id)
        end
      end

      response(404, "borrowing not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }
        let(:params) {
          {
            borrowing: {
              book_copy_id: create(:book_copy).id,
              user_id: create(:user).id,
              borrowed_at: Time.zone.now,
              due_date: Time.zone.now + 3.week,
              returned_at: nil,
            },
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end

    delete "Librarian delete borrowing" do
      tags "Librarian Borrowings"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "borrowing deleted") do
        let(:id) { borrowings.last.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns no content" do
          expect(response).to have_http_status(:no_content)
        end
      end

      response(404, "borrowing not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end
  end

  path "/v1/librarian/borrowings/{id}/return" do
    patch "Librarian return borrowing" do
      tags "Librarian Borrowings"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response(200, "borrowing returned") do
        schema type: :object,
               properties: {
                 book_copy_id: { type: :integer },
                 user_id: { type: :integer },
                 borrowed_at: { type: :string },
                 due_date: { type: :string },
                 returned_at: { type: :string },
               },
               required: %w[book_copy_id user_id borrowed_at due_date returned_at]

        let(:id) { borrowings.last.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns borrowing" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body["returned_at"]).to be_truthy
          expect(body["book_copy_id"]).to eq(borrowings.last.book_copy_id)
        end
      end

      response(404, "borrowing not found") do
        schema type: :object,
               properties: {
                 error: { type: :string },
               }

        let(:id) { 0 }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns not found" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:not_found)
          expect(body["errors"]).to include("not found")
        end
      end
    end
  end
end
