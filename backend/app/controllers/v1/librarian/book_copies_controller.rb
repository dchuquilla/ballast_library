class V1::Librarian::BookCopiesController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action :set_book_copy, only: [:show, :update, :destroy]

  def index
    @book_copies = BookCopy.where(book_id: params[:id])
    render json: @book_copies, status: :ok
  end

  def show
    render json: @book_copy, status: :ok
  end

  def create
    @book_copy = BookCopy.new(book_copy_params)

    if @book_copy.save
      render json: @book_copy, status: :created
    else
      render json: { errors: @book_copy.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book_copy.update(update_copy_params)
      render json: @book_copy, status: :ok
    else
      render json: { errors: @book_copy.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book_copy.destroy
    head :no_content
  end

  private

  def book_copy_params
    params.require(:book_copy).permit(:book_id, :status)
  end

  def update_copy_params
    params.require(:book_copy).permit(:copy_code, :status)
  end

  def set_book_copy
    @book_copy = BookCopy.find_by(id: params[:book_copy_id], book_id: params[:id])
  end
end
