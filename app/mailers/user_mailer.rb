class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Alice account activation"
  end

  def email_verification(user)
    @user = user
    mail to: user.email, subject: "Alice email verification"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Alice password reset"
  end
end