class Location < ActiveRecord::Base
  # validates_presence_of :city_to, :city_from, :gas_mileage, :gas_price
  
  # validates_numericality_of :gas_mileage, :message => "please enter the number of miles your car gets per gallon (numbers only)."

# These methods are for getting the gas cost - VIA GEOKIT & GOOGLE MAPS

  def car_gas_cost()
    origin = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_to}"
    destination = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_from}"
    cost = (origin.distance_to(destination) / gas_mileage) * gas_price
    cost
  end
  
  def car_round_trip()
    car_gas_cost*2
  end
  
  def fixed_car_gas_cost()
    origin = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_to}"
    destination = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_from}"
    cost = (origin.distance_to(destination) / 25) * 2.73 # as of 5/30/2010 at http://www.fuelgaugereport.com/
    cost
  end
  
  def fixed_car_round_trip()
    fixed_car_gas_cost*2
  end

# These methods are for getting the flight cost - FROM KAYAK

  def origin_iata_code()
     if IATA_CITY_CODE_MAPPING.has_key?(city_from)
       origin_find_code = IATA_CITY_CODE_MAPPING.fetch(city_from) 
     end
   origin_find_code
  end

  def destination_iata_code()
    if IATA_CITY_CODE_MAPPING.has_key?(city_to)
       destination_find_code = IATA_CITY_CODE_MAPPING.fetch(city_to) 
     end
   destination_find_code
  end
  
  def kayak_feed_date()
    t = Time.now
    t.strftime("%m%Y")
  end
  
  def get_kayak_feed()
     feed = FeedNormalizer::FeedNormalizer.parse open("http://www.kayak.com/h/rss/fare?code=#{origin_iata_code}&dest=#{destination_iata_code}&tm=#{kayak_feed_date}")
     feed.entries.first.title
  end
  
IATA_CITY_CODE_MAPPING = { "Atlanta, GA" => "ATL",
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
                        "Colorado Springs, CO" => "COS",
                        "Dallas, TX" => "DFW",
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
                        "St Louis, MO" => "STL",
                        "Tampa, FL" => "TPA",
                        "Washington, DC - IAD" => "IAD", #need to make sure to change the D.C. to DC to adhere to Greyhound 
                        "Washington, DC - DCA" => "DCA"}
                        
# These methods are to interpolate the url string with the parameters from the view
# This is to get the bus cost
# parameters for the url string interpolation

T = 8.hours.from_now


  def dYear
    T.strftime("1"+"%y") #the formatting in the greyhound url is 1 + the last two digits of the current year ie, 110 for the year 2010
  end

  def dMonth
    T.month
  end

  def dDay
    T.day
  end

  def rYear
    t = 7.days.from_now #same formatting as the dYear
    t.strftime("1"+"%y")
  end

  def rMonth
    7.days.from_now.month
  end

  def rDay
    7.days.from_now.day
  end
  
  def busOriginState
    regex_parse = /[A-Z]{2}/
    regex_test1 = Regexp.new(regex_parse)
    matchdata = regex_test1.match(city_from)
    matchdata.to_s
  end
  
  def busOriginCity
     city_from_regex = /^[^,]*/
     regex_test1 = Regexp.new(city_from_regex)
     matchdata = regex_test1.match(city_from)
     cgi_escaped_city = CGI.escape(matchdata.to_s)
     cgi_escaped_city
   end
   
   def busDestinationState
     regex_parse = /[A-Z]{2}/
     regex_test1 = Regexp.new(regex_parse)
     matchdata = regex_test1.match(city_to)
     matchdata.to_s
   end

   def busDestinationCity
      city_to_regex = /^[^,]*/
      regex_test1 = Regexp.new(city_to_regex)
      matchdata = regex_test1.match(city_to)
      cgi_escaped_city = CGI.escape(matchdata.to_s)
      cgi_escaped_city
    end
  
  # Need to format the views to match the right formatting in the url

  def get_bus_cost()
   doc = open("https://www.greyhound.com/farefinder/step2.aspx?Redirect=Y&Version=1.0&OriginID=340660&OriginCity=#{busOriginCity}&OriginState=#{busOriginState}&DestinationID=151239&DestinationCity=#{busDestinationCity}&DestinationState=#{busDestinationState}&Children=0&Legs=1&Adults=1&Seniors=0&DYear=#{dYear}&DMonth=#{dMonth}&DDay=#{dDay}&DHr=&RYear=#{rYear}&RMonth=#{rMonth}&RDay=#{rDay}&RHr=") { |f| Hpricot(f) }
   bus_price = doc.at("#ctl00_ContentHolder_DepartureGrid_ctl00__2 :nth-child(5)").to_plain_text[/\$[0-9\.]+/]
    if bus_price == nil
      "Sorry, nothing available at this time."
    else
      bus_price
    end  
  end
end

