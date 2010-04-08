class Notifications < ActionMailer::Base
    def contact(email_params)
      subject "[Getset] " << email_params[:subject]
      recipients "feedback@getsetapp.com"
      from email_params[:email]
      sent_on Time.now.utc

      body :message => email_params[:body], :name => email_params[:name]
    end
end


