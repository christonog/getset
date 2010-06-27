class ContactController < ApplicationController
  before_filter :set_title, :set_meta_description
  
  def set_meta_description
      @meta_description = "Compare travel methods and travel costs with Getset in seconds. Whether by plane, car, or bus, it's so easy to find out how much it costs to travel to your destination." 
   end

   def set_title
   end
  
  def index
    @title = "Contact Us"
    # render index.html.erb
  end

  def create
    if Notifications.deliver_contact(params[:contact])
      flash[:notice] = "Email was successfully sent."
      redirect_to(contact_path)
    else
      flash.now[:error] = "An error occurred while sending this email."
      render :index
    end
  end
  
end
