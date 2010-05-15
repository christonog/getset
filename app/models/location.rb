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
   origin_iata_city_codes = { "Atlanta, GA" => "ATL",
                              "Anchorage, AL" => "ANC",
                              "Austin, TX" => "AUS",
                              "Baltimore, MD" => "BWI",
                              "Boston, MA" => "BOS",
                              "Charlotte, NC" => "CLT",
                              "Chicago, IL" => "MDW",
                              "Chicago, IL" => "ORD",
                              "Cincinnati, OH" => "CVG", 
                              "Cleveland, OH" => "CLE",
                              "Columbus, OH" => "CMH",
                              "Dallas/Ft. Worth, TX" => "DFW",
                              "Denver, CO" => "DEN",
                              "Detroit, MI" => "DTW",
                              "Fort Lauderdale, FL" => "FLL",
                              "Fort Meyers, FL" => "RSW",
                              "Hartford, CT" => "BDL",
                              "Houston, TX - IAH" => "IAH",
                              "Houston, TX - HOU" => "HOU",
                              "Indianapolis, IN" => "IND",
                              "Kansas City, MO" => "MCI",
                              "Las Vegas, NV" => "LAS", 
                              "Los Angeles, CA" => "LAX",                                                                                                            
                              "Memphis, TN" => "MEM",
                              "Miami, FL" => "MIA",
                              "Minneapolis, MN" => "MSP",
                              "Nashville, TN" => "BNA",
                              "New Orleans, LA" => "MSY",
                              "New York, NY - JFK" => "JFK", 
                              "New York, NY - LGA" => "LGA",
                              "Newark, NJ" => "EWR",
                              "Oakland, CA" => "OAK",                                                      
                              "Ontario, CA" => "ONT",
                              "Orlando, CA" => "MCO",
                              "Philadelphia, PA" => "PHL",
                              "Phoenix, AZ" => "PHX",
                              "Pittsburgh, PA" => "PIT",
                              "Portland, OR" => "PDX",
                              "Raleigh, NC" => "RDU",
                              "Sacramento, CA" => "SMF",
                              "Salt Lake City, UT" => "SLC",
                              "San Antonio, TX" => "SAT",
                              "San Diego, CA" => "SAN",
                              "San Francisco, CA" => "SFO",
                              "San Jose, CA" => "SJC",
                              "Santa Ana, CA" => "SNA",
                              "Seattle, WA" => "SEA",
                              "St. Louis, MO" => "STL",
                              "Tampa, FL" => "TPA",
                              "Washington, D.C. - IAD" => "IAD",
                              "Washington, D.C. - DCA" => "DCA"}
                              
     if origin_iata_city_codes.has_key?(city_from)
       origin_find_code = origin_iata_city_codes.fetch(city_from) 
     end
   origin_find_code
  end

  def destination_iata_code()
   destination_iata_city_codes =  { "Atlanta, GA" => "ATL",
                                "Anchorage, AL" => "ANC",
                                "Austin, TX" => "AUS",
                                "Baltimore, MD" => "BWI",
                                "Boston, MA" => "BOS",
                                "Charlotte, NC" => "CLT",
                                "Chicago, IL" => "MDW",
                                "Chicago, IL" => "ORD",
                                "Cincinnati, OH" => "CVG", 
                                "Cleveland, OH" => "CLE",
                                "Columbus, OH" => "CMH",
                                "Dallas/Ft. Worth, TX" => "DFW",
                                "Denver, CO" => "DEN",
                                "Detroit, MI" => "DTW",
                                "Fort Lauderdale, FL" => "FLL",
                                "Fort Meyers, FL" => "RSW",
                                "Hartford, CT" => "BDL",
                                "Houston, TX - IAH" => "IAH",
                                "Houston, TX - HOU" => "HOU",
                                "Indianapolis, IN" => "IND",
                                "Kansas City, MO" => "MCI",
                                "Las Vegas, NV" => "LAS", 
                                "Los Angeles, CA" => "LAX",                                                                                                            
                                "Memphis, TN" => "MEM",
                                "Miami, FL" => "MIA",
                                "Minneapolis, MN" => "MSP",
                                "Nashville, TN" => "BNA",
                                "New Orleans, LA" => "MSY",
                                "New York, NY - JFK" => "JFK", 
                                "New York, NY - LGA" => "LGA",
                                "Newark, NJ" => "EWR",
                                "Oakland, CA" => "OAK",                                                      
                                "Ontario, CA" => "ONT",
                                "Orlando, CA" => "MCO",
                                "Philadelphia, PA" => "PHL",
                                "Phoenix, AZ" => "PHX",
                                "Pittsburgh, PA" => "PIT",
                                "Portland, OR" => "PDX",
                                "Raleigh, NC" => "RDU",
                                "Sacramento, CA" => "SMF",
                                "Salt Lake City, UT" => "SLC",
                                "San Antonio, TX" => "SAT",
                                "San Diego, CA" => "SAN",
                                "San Francisco, CA" => "SFO",
                                "San Jose, CA" => "SJC",
                                "Santa Ana, CA" => "SNA",
                                "Seattle, WA" => "SEA",
                                "St. Louis, MO" => "STL",
                                "Tampa, FL" => "TPA",
                                "Washington, D.C. - IAD" => "IAD",
                                "Washington, D.C. - DCA" => "DCA"}
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

