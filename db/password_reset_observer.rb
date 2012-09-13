class PasswordResetObserver

  include DataMapper::Observer

  observe PasswordReset

  after :save do
    if SEND_MAIL
      PasswordResetMailer.password_reset(self).deliver
    else
      puts 'Sending email'
    end
  end
end

class PasswordResetMailer < ActionMailer::Base
  default from: 'redmine@aumgn.fr'

  def password_reset(to)
    mail to: 'aumgn@free.fr', subject: 'Hi', body: 'Hello there !'
  end
end
