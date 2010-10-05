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

    location_from, location_to = [city_from, city_to].collect {|user_location| get_amtrak_location_name_for user_location}

    if location_from && location_to
      min_price_trip_for_departure   = get_amtrak_min_price_for location_from, location_to, 1.week.from_now
      min_price_trip_for_return      = get_amtrak_min_price_for location_to, location_from, 2.weeks.from_now
    end

    min_price = (min_price_trip_for_departure + min_price_trip_for_return) if (min_price_trip_for_departure && min_price_trip_for_return)

    if min_price
      {
        :found => true,
        :amount => "$#{min_price}"
      }
    else
      {
        :found => false,
        :amount => 'Sorry, nothing available at this time.'
      }
    end

  end

  def to_param
    "/#{id}-to-#{city_to.gsub(/[^a-z0-9]+/i, '-')}-from-#{city_from.gsub(/[^a-z0-9]+/i, '-')}"
  end



  private

  def get_amtrak_location_name_for(location)
      # Taking user-specified city name with regexp and getting right location string from Amtrak
      Hpricot(Typhoeus::Request.post("http://tickets.amtrak.com/itd/amtrak/AutoComplete",
                             :params => {'_origin' => "#{location.scan(/^[\s\w]*/).to_s}"},
                             :timeout       => 10000, # milliseconds
                             :cache_timeout => 3600   # seconds
                            ).body).search("//li")[0].try(:html)
  end

  def get_amtrak_min_price_for(location_from, location_to, departure_date)

      # Getting Amtrak search results HTML content
      page = Typhoeus::Request.post("http://tickets.amtrak.com/itd/amtrak",
                :params => {

                    # Locations
                    'wdf_origin' => location_from,
                    'wdf_destination' => location_to,

                    # Departure date
                    "/sessionWorkflow/productWorkflow[@product='Rail']/tripRequirements/journeyRequirements[1]/departDate.date" => "#{departure_date.strftime("%a, %b %d, %Y")}",

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

                :timeout       => 10000, # milliseconds
                :cache_timeout => 3600   # seconds
       ).body

       doc = Hpricot(page)

       # Searching for DIV with lowest prices, taking out prices with regexp, finding minimal
       min_price = doc.search("//div[@id='matrix_lowest_price']")[0].to_s.scan(/\$([\d.]*)/).flatten.collect(&:to_i).min
  end

end


