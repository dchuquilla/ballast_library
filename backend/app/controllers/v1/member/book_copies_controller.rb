class V1::Member::BookCopiesController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!

  def index
    @book_copies = BookCopy.where(book_id: params[:id])
    render json: @book_copies, status: :ok
  end

  def show
    @book_copy = BookCopy.find_by(book_id: params[:id], id: params[:book_copy_id])
    render json: @book_copy, status: :ok
  end
end
