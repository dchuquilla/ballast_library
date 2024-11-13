class V1::Member::BorrowingsController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action :set_borrowing, only: [:show]

  def index
    @borrowings = Borrowing.where(user: current_user)
    render json: @borrowings, status: :ok
  end

  def show
    render json: { error: "Not Found" }, status: :not_found and return unless @borrowing

    render json: @borrowing, status: :ok
  end

  def borrow
    service = BorrowBookService.new(current_user, borrowing_params)
    if service.call[:success]
      render json: service.borrowing, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_borrowing
    @borrowing = Borrowing.find_by(user_id: current_user.id, id: params[:id])
  end

  def borrowing_params
    params.require(:borrowing).permit(:book_copy_id)
  end
end
