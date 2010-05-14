class Location < ActiveRecord::Base
  # validates_presence_of :city_to, :city_from, :gas_mileage, :gas_price
  
  # validates_numericality_of :gas_mileage, :message => "please enter the number of miles your car gets per gallon (numbers only)."
  
  def gas_cost()
    origin = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_to}"
    destination = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_from}"
    cost = (origin.distance_to(destination) / gas_mileage) * gas_price
    cost
  end
  
  def round_trip()
    gas_cost*2
  end
  
  def origin_iata_code()
   origin_iata_city_codes = { "Raleigh, NC" => "RDU", "Los Angeles, CA" => "LAX" }
     if origin_iata_city_codes.has_key?(city_from)
       origin_find_code = origin_iata_city_codes.fetch(city_from) 
     end
   origin_find_code
  end

  def destination_iata_code()
   destination_iata_city_codes = { "Raleigh, NC" => "RDU", "Los Angeles, CA" => "LAX" }
    if destination_iata_city_codes.has_key?(city_to)
       destination_find_code = destination_iata_city_codes.fetch(city_to) 
     end
   destination_find_code
  end
  
  def get_kayak_feed()
     feed = FeedNormalizer::FeedNormalizer.parse open("http://www.kayak.com/h/rss/fare?code=#{origin_iata_code}&dest=#{destination_iata_code}&tm=201005")
     feed.entries.first.title
  end
end

