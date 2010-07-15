class LocationController < ApplicationController
  before_filter :set_title, :set_meta_description
  
  def set_meta_description
     @meta_description = "Compare travel methods and travel costs with Getset in seconds. Whether by plane, car, or bus, it's so easy to find out how much it costs to travel to your destination." 
  end
  
  def set_title
  end
  
  def start
     @title = "Compare and find flight, car, and bus travel costs | Getset" 
  end

  def results 
    @location = Location.new(params[:location])
    @title = "flight, car, and bus travel cost comparison from #{@location.city_from} to #{@location.city_to}"
    @time = 1.day.from_now.strftime("%m/%d/%Y")
    @future_time = 7.days.from_now.strftime("%m/%d/%Y")  
  end
  
  #might have to add a new action here to retrieve items already saved in the db.
  
  def about
    @title = "About Us | Getset"
  end
  
  def faq
    @title = "Frequently Asked Questions | Getset"
  end
  
  def terms_privacy
    @title = "Terms and Privacy"
  end

end
