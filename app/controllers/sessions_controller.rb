class SessionsController < ApplicationController
  def new
  end

  ## Log a user in.
  def create

    ## Bail if reCAPTCHA invalid.
    unless verify_recaptcha()
      flash[:danger] = "Cannot verify reCAPTCHA."
      redirect_to edit_user_path(current_user)
      return
    end 

    ## Check if it's an email, not a username.
    if(params[:session][:username] =~ /.*@.*/)
      user = User.find_by(email: params[:session][:username])
    else
      user = User.find_by(username: params[:session][:username])
    end

    if not user.nil? and !user.is_stub? and user.authenticate(params[:session][:password])
      if !user.deleted? and user.activated?
        ## Log in.
        log_in user

        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        flash[:info] = "Welcome back! You are now logged in"
        redirect_back_or root_url
      elsif user.deleted?
          message = "Account has been deleted."
          flash.now[:warning] = message
          render 'new'
      else
        message = "Account not activated. "+
          "Check your email for the activation link or click "+
          "\"Forgot password\" to a have a new one emailed to you."
        flash.now[:warning] = message
        render 'new'
      end
    elsif user and user.is_stub?
      message = "This account is only a stub; to claim it, click "+
        "\"Forgot password\" to a have a password reset link emailed to you."
        flash.now[:warning] = message
        render 'new'
    else
      ## Error!
      flash.now[:danger] = 'Invalid username/email and password combination'
      render 'new'
      # redirect_to login_path
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