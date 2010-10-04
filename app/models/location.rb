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

  def get_bus_cost

    # Get Amtrak locations

    locations_from = Typhoeus::Request.post("http://tickets.amtrak.com/itd/amtrak/AutoComplete", :params => {'_origin' => "#{self.city_from.scan(/^[\s\w]*/).to_s}"}).body
    location_from = Hpricot(locations_from).search("//li")[0].try(:html)

    locations_to = Typhoeus::Request.post("http://tickets.amtrak.com/itd/amtrak/AutoComplete", :params => {'_origin' => "#{self.city_to.scan(/^[\s\w]*/).to_s}"}).body
    location_to = Hpricot(locations_to).search("//li")[0].try(:html)

    if location_from && location_to

      page = Typhoeus::Request.post("http://tickets.amtrak.com/itd/amtrak",
                :params => {

                    # Locations
                    'wdf_origin' => location_from,
                    'wdf_destination' => location_to,

                    # Departure date(tomorrow by default)
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/journeyRequirements[1]/departDate.date" => "#{Date.tomorrow.strftime("%a, %b %d, %Y")}",

                    'requestor' => 'amtrak.presentation.handler.page.rail.AmtrakRailFareFinderPageHandler',
                    "xwdf_TripType" => "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/tripType",
                    "wdf_TripType" => 'OneWay',
                    "xwdf_TripType" => "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/tripType",
                    "xwdf_origin" => "/sessionWorkflow/productWorkflow[@product='Rail']/travelSelection/journeySelection[1]/departLocation/search",
                    "xwdf_destination" => "/sessionWorkflow/productWorkflow[@product='Rail']/travelSelection/journeySelection[1]/arriveLocation/search",
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/journeyRequirements[1]/departTime.hourmin" => '',
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/journeyRequirements[2]/departDate.date" => '',
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/journeyRequirements[2]/departTime.hourmin" => '',
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/allJourneyRequirements/numberOfTravellers[@key='Adult']" => 1,
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/allJourneyRequirements/numberOfTravellers[@key='Child']" => 0,
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/allJourneyRequirements/numberOfTravellers[@key='Infant']" => 0,
                    "_handler=amtrak.presentation.handler.request.rail.AmtrakRailSearchRequestHandler/_xpath=/sessionWorkflow/productWorkflow[@product='Rail'].x" => 17,
                    "_handler=amtrak.presentation.handler.request.rail.AmtrakRailSearchRequestHandler/_xpath=/sessionWorkflow/productWorkflow[@product='Rail'].y" => 15
                },

                :headers       => {:user_agent => "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)"},
                :timeout       => 10000, # milliseconds
                :cache_timeout => 120   # seconds
       ).body

       doc = Hpricot(page)

       # Search for DIV, take out prices with regexp, find minimal
       min_price = doc.search("//div[@id='matrix_lowest_price']")[0].to_s.scan(/\$([\d.]*)/).flatten.collect(&:to_i).min
    end

     min_price ? "$#{min_price}" : "Sorry, nothing available at this time."

  end

  def to_param
    "/#{id}-to-#{city_to.gsub(/[^a-z0-9]+/i, '-')}-from-#{city_from.gsub(/[^a-z0-9]+/i, '-')}"
  end
end

