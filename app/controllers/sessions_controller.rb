class SessionsController < ApplicationController
  def new
  end

  ## Log a user in.
  def create
    user = User.find_by(username: params[:session][:username])
    if user and user.authenticate(params[:session][:password])
      if user.activated?
        ## Log in.
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or root_url
      else
        message = "Account not activated."
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      ## Error!
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  ## Log the user out if they're logged in; display an error message otherwise.
  def destroy
    ## The user is logged in; log them out and send them to the homepage.
    if logged_in?
      log_out 
      flash[:info] = "You are now logged out."
      redirect_to :root
      
    ## The user isn't logged in; display a message on the current page.
    else
      flash[:warning] = "No user is currently logged in."
      if request.referrer and not request.referrer.empty?
        redirect_to request.referrer
      else
        redirect_to :root
      end
    end
  end

end