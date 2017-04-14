class EmailVerificationsController < ApplicationController
  def edit
    user = User.find_by(username: params[:username])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Email verified!"
      redirect_to root_url
    else
      flash[:danger] = "Invalid activation link."
      redirect_to root_url
    end
  end
end
