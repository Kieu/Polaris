class SendMail
  include Resque::Plugins::Status
  @queue = :send_mail

  def perform
    UserMailer.send_password(options['user'], options['password']).deliver
  end
end
