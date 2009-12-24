class Location < ActiveRecord::Base
  
  validates_presence_of :city_to, :city_from, :gas_mileage, :gas_price
  
  validates_numericality_of :gas_mileage, :message => "please enter the number of miles your car gets per gallon (numbers only)."
    
  def gas_cost()
    origin = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_to}"
    destination = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_from}"
    cost = (origin.distance_to(destination) / gas_mileage) * gas_price
    cost
  end
  
  def round_trip()
    gas_cost*2
  end
end
