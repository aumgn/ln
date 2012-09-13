class PasswordResetObserver

  include DataMapper::Observer

  observe PasswordReset

  after :save do
    body = <<-BODY
   Here's the link to activate your account.
   http#{USE_SSL ? "s" : ""}://#{BASE_URL}/~#{token}
BODY
    if SEND_MAIL
      Pony.mail(to: user.email, subject: "[ln2] Activation", body: body)
    else
      puts "Sending email :\n"
      puts body
    end
  end
end
