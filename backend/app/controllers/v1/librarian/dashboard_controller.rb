# frozen_string_literal: true

class V1::Librarian::DashboardController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action only: [:index] do
    custom_authorize("LibrarianDashboard", "#{params[:action]}?")
  end

  def index
    render json: LibrarianDashboardPresenter.new().as_json, status: :ok
  end
end
