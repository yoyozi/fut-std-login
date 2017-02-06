class ContactMailer < ActionMailer::Base
  default to: "craig@yoyozi.com"
  
  def contact_email(name, email, message)
    @name = name
    @email = email
    @message = message

  
  mail(from: email, subject: "Steve's Articles Contact Form Message")
  end
end