class UserMailer < ApplicationMailer
  def confirmation_email(user, raw_token)
    @user      = user
    @raw_token = raw_token

    mail(to: @user.email, subject: "Confirm your email address")
  end

  def reset_password_email(user, raw_token)
    @user      = user
    @raw_token = raw_token

    mail(to: @user.email, subject: "Reset your password")
  end
end
