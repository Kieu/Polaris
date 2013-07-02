class UserMailer < ActionMailer::Base
  default from: Settings.mailer.default_from

  def send_password user, password
    @user = user
    @password = password
    mail(to: user['email'], subject: Settings.mailer.send_password_subject) do |format|
      format.html
      format.text
    end
  end
end