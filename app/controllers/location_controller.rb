class LocationController < ApplicationController
  before_filter :set_title, :set_meta_description
  
  def set_meta_description
     @meta_description = "Calculate your travel costs with Getset. Enter your travel destination, your current location, gas price,
      and your car's gas mileage. Give Getset a try! It's so easy to find out how much it costs to travel to your destination. You can change the
      gas price and gas mileage to get a more accurate calculation of your driving costs."
  end
  
  def set_title
  end
  
  def start
     @title = "Getset | Find out your travel costs" 
  end

  def results
    @location = Location.new(params[:location])
    @title = "Flight and driving cost from #{@location.city_from} to #{@location.city_to}"
    @time = 8.hours.from_now.strftime("%m/%d/%Y")
    @future_time = 7.days.from_now.strftime("%m/%d/%Y")  
  end
  
  def about
    @title = "Getset | About Us"
  end

end
