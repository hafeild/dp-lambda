class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(username: params[:username])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to :projects
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
