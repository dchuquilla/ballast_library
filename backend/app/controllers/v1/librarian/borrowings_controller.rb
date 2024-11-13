class V1::Librarian::BorrowingsController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action :set_borrowing, only: [:show, :update, :destroy, :return]

  def index
    @borrowings = Borrowing.all
    render json: @borrowings, status: :ok
  end

  def show
    render json: @borrowing, status: :ok
  end

  def update
    if @borrowing.update(borrowing_params)
      render json: @borrowing, status: :ok
    else
      render json: { errors: @borrowing.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @borrowing.destroy
    head :no_content
  end

  def return
    service = ReturnBookService.new(@borrowing)
    result = service.call
    if result[:success]
      render json: result[:borrowing], status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def borrowing_params
    params.require(:borrowing).permit(:book_copy_id, :user_id, :borrowed_at, :due_date, :returned_at)
  end

  def set_borrowing
    @borrowing = Borrowing.find(params[:id])
  end
end
