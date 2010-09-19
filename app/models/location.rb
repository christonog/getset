require 'open-uri'
class Location < ActiveRecord::Base
  # validates_presence_of :city_to, :city_from, :gas_mileage, :gas_price
    
  # validates_numericality_of :gas_mileage, :message => "please enter the number of miles your car gets per gallon (numbers only)."

  # These methods are for getting the gas cost - VIA GEOKIT & GOOGLE MAPS

  def car_gas_cost
    origin = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_to}"
    destination = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_from}"
    cost = (origin.distance_to(destination) / gas_mileage) * gas_price
    cost
  end

  def car_round_trip
    car_gas_cost*2
  end

  def fixed_car_gas_cost
    origin = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_to}"
    destination = Geokit::Geocoders::GoogleGeocoder.geocode "#{city_from}"
    cost = (origin.distance_to(destination) / 30) * 2.50 # as of 5/30/2010 at http://www.fuelgaugereport.com/
    cost
  end

  def fixed_car_round_trip
    fixed_car_gas_cost*2
  end

  # These methods are for getting the flight cost - FROM KAYAK

  def origin_iata_code
    Iata.find_by_iata_city(city_from).try(:iata_code)
  end

  def destination_iata_code
    Iata.find_by_iata_city(city_to).try(:iata_code)
  end
  
  def get_kayak_feed
    p url = "http://www.kayak.com/h/rss/fare?code=#{origin_iata_code}&dest=#{destination_iata_code}&tm=#{Time.now.strftime("%m%Y")}"
    feed = FeedNormalizer::FeedNormalizer.parse(open(url))
    if feed.entries.first.title == nil
      "Sorry, nothing available at this time."
    else
      feed.entries.first.title
    end
  end

  # These methods are to interpolate the url string with the parameters from the view
  # This is to get the bus cost

  T = 1.day.from_now


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

#  def get_bus_cost
#    post_url  = 'https://www.greyhound.com/services/farefinder.asmx/Search'
#    post_body = ""
#  end

  def get_bus_cost
    p url = "https://www.greyhound.com/farefinder/step2.aspx?Redirect=Y&Version=1.0&OriginCity=#{busOriginCity}&OriginState=#{busOriginState}&DestinationCity=#{busDestinationCity}&DestinationState=#{busDestinationState}&Children=0&Legs=2&Adults=1&Seniors=0&DYear=#{dYear}&DMonth=#{dMonth}&DDay=#{dDay}&DHr=&RYear=#{rYear}&RMonth=#{rMonth}&RDay=#{rDay}&RHr="
    doc = open(url) { |f| Hpricot(f) }
    bus_price = doc.at("#ctl00_ContentHolder_DepartureGrid_ctl00__0 :nth-child(5)")
    if bus_price == nil
      "Sorry, nothing available at this time."
    else
      bus_price.to_plain_text[/\$[0-9\.]+/]
    end
  end

  def to_param
    "/#{id}-to-#{city_to.gsub(/[^a-z0-9]+/i, '-')}-from-#{city_from.gsub(/[^a-z0-9]+/i, '-')}"
  end
end

