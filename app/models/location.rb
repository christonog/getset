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
    unless feed.entries.blank?
      if feed.entries.first.title == nil
        "Sorry, nothing available at this time."
      else
        feed.entries.first.title
      end
    end
  end

  # These methods are to interpolate the url string with the parameters from the view
  # This is to get the bus cost - lines 56-112 depreciated in favor of Vladimir's changes.
=begin
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
=end

  def get_amtrak_cost

    location_from, location_to = [city_from, city_to].collect {|user_location| get_amtrak_location_name_for user_location}

    unless location_from.blank? && location_to.blank?
      min_price_trip_for_departure   = get_amtrak_min_price_for location_from, location_to, 1.week.from_now
      min_price_trip_for_return      = get_amtrak_min_price_for location_to, location_from, 2.weeks.from_now
      min_price = (min_price_trip_for_departure + min_price_trip_for_return) if (min_price_trip_for_departure && min_price_trip_for_return)
    end

    if min_price
      {
        :found => true,
        :amount => "$#{min_price}"
      }
    else
      {
        :found => false,
        :amount => 'Sorry, It appears that one of your selected cities does not have a train station nearby.'
      }
    end

  end

  def get_greyhound_cost

    location_from, location_to = [city_from, city_to].collect {|user_location| get_greyhound_location_name_for user_location}

    unless location_from.blank? && location_to.blank?
      min_price = get_greyhound_min_price_for(location_from, location_to, 1.week.from_now, 2.weeks.from_now)
    end

    if min_price
      {
        :found => true,
        :amount => "$#{min_price}"
      }
    else
      {
        :found => false,
        :amount => 'Sorry, nothing available at this time'
      }
    end

  end

private
  # private Amtrak methods
  def get_amtrak_location_name_for(location)

    city = Iata.find_by_iata_city(location)

    amtrak_location = unless city.amtrak_code.blank?
      response = Hpricot(Typhoeus::Request.post("http://tickets.amtrak.com/itd/amtrak/AutoComplete",
                                               :params => {'_origin' => "#{city.amtrak_code}"},
                                               :timeout       => 10000, # milliseconds
                                               :cache_timeout => 3600   # seconds
                                              ).body).search("//li").collect(&:html).try(:first)

      response if response != "No stations match your entry."
    end

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

  #private Greyhound Methods

  def get_greyhound_location_name_for(location)

    city = Iata.find_by_iata_city(location)

    agent = Mechanize.new
    agent.log = Logger.new(STDOUT)
    agent.request_headers = {
      'Host'=>'www.greyhound.com' ,
      'User-Agent'=>'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10' ,
      'Accept'=>'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' ,
      'Accept-Language'=>'en-us,en;q=0.5' ,
      'Accept-Encoding'=>'gzip,deflate' ,
      'Accept-Charset'=>'ISO-8859-1,utf-8;q=0.7,*;q=0.7' ,
      'Keep-Alive'=>'115' ,
      'Connection'=>'keep-alive'
    }
    agent.get('http://www.greyhound.com/')

    response = Typhoeus::Request.post("http://www.greyhound.com/services/locations.asmx/GetOriginLocationsByName",
                                     :headers       => {
      'Host'=>'www.greyhound.com' ,
      :Agent=>'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10' ,
      :Accepts=>'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' ,
      'Accept-Language'=>'en-us,en;q=0.5' ,
      #'Accept-Encoding'=>'gzip,deflate' ,
      'Accept-Charset'=>'ISO-8859-1,utf-8;q=0.7,*;q=0.7' ,
      'Keep-Alive'=>'115' ,
      'Connection'=>'keep-alive' ,
      'Content-Type'=>'application/json; charset=utf-8' ,
      'Referer'=>'https://www.greyhound.com' ,
      #'Content-Length'=>'377',
      'Cookie'=>"ASP.NET_SessionId=#{agent.cookies.first.value}",
    },
      #:body         => '{"request":{"__type":"Greyhound.Website.DataObjects.ClientSearchRequest","Mode":0,"Origin":"151239|New York/NY","Destination":"892001|Los Angeles/CA","Departs":"\/Date(1287853200000)\/","Returns":"\/Date(1288458000000)\/","TimeDeparts":null,"TimeReturns":null,"RT":true,"Adults":1,"Seniors":0,"Children":0,"PromoCode":"","DiscountCode":"","Card":"","CardExpiration":"10/2010"}}'
      :body         => "{\"context\":{\"Text\":\"#{location.scan(/^([\w\s]*,\s\w*)/).to_s}\",\"NumberOfItems\":0}}"
                                    ).body

    JSON.parse(response)['d']['Items'].first['Value']

  end

  def get_greyhound_min_price_for(location_from, location_to, departure_date, returning_date)

    agent = Mechanize.new
    agent.log = Logger.new(STDOUT)
    agent.request_headers = {
      'Host'=>'www.greyhound.com' ,
      'User-Agent'=>'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10' ,
      'Accept'=>'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' ,
      'Accept-Language'=>'en-us,en;q=0.5' ,
      'Accept-Encoding'=>'gzip,deflate' ,
      'Accept-Charset'=>'ISO-8859-1,utf-8;q=0.7,*;q=0.7' ,
      'Keep-Alive'=>'115' ,
      'Connection'=>'keep-alive'
    }
    agent.get('http://www.greyhound.com/')

    #debugger

    request_body = '{"request":{"__type":"Greyhound.Website.DataObjects.ClientSearchRequest","Mode":0,"Origin":"'+location_from+'","Destination":"'+location_to+'","Departs":"\/Date('+departure_date.to_date.to_time.to_i.to_s+'000)\/","Returns":"\/Date('+returning_date.to_date.to_time.to_i.to_s+'000)\/","TimeDeparts":null,"TimeReturns":null,"RT":true,"Adults":1,"Seniors":0,"Children":0,"PromoCode":"","DiscountCode":"","Card":"","CardExpiration":"10/2010"}}'
    #request_body = '{"request":{"__type":"Greyhound.Website.DataObjects.ClientSearchRequest","Mode":0,"Origin":"893420|Santa Barbara/CA","Destination":"240317|Detroit/MI","Departs":"\/Date(1288458000000)\/","Returns":"\/Date(1289066400000)\/","TimeDeparts":null,"TimeReturns":null,"RT":true,"Adults":1,"Seniors":0,"Children":0,"PromoCode":"","DiscountCode":"","Card":"","CardExpiration":"10/2010"}}'

    request = Typhoeus::Request.post("http://www.greyhound.com/services/farefinder.asmx/Search",
                                     :method        => :post,
                                     :headers       => {
      #'Host'=>'www.greyhound.com' ,
      #:Agent=>'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10' ,
      #:Accepts=>'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' ,
      #'Accept-Language'=>'en-us,en;q=0.5' ,
      #'Accept-Encoding'=>'gzip,deflate' ,
      #'Accept-Charset'=>'ISO-8859-1,utf-8;q=0.7,*;q=0.7' ,
      #'Keep-Alive'=>'115' ,
      #'Connection'=>'keep-alive' ,
      'Content-Type'=>'application/json; charset=utf-8' ,
      'Referer'=>'https://www.greyhound.com' ,
      'Content-Length'=> "#{request_body.length}",
      #'Content-Length'=> "377",
      'Cookie'=>"ASP.NET_SessionId=#{agent.cookies.first.value}",
    },
      #:body         => '{"request":{"__type":"Greyhound.Website.DataObjects.ClientSearchRequest","Mode":0,"Origin":"151239|New York/NY","Destination":"892001|Los Angeles/CA","Departs":"\/Date(1288458000000)\/","Returns":"\/Date(1289066400000)\/","TimeDeparts":null,"TimeReturns":null,"RT":true,"Adults":1,"Seniors":0,"Children":0,"PromoCode":"","DiscountCode":"","Card":"","CardExpiration":"10/2010"}}'
      #:body         => '{"request":{"__type":"Greyhound.Website.DataObjects.ClientSearchRequest","Mode":0,"Origin":"350636|Charleston/SC","Destination":"350262|Columbia/SC","Departs":"/Date(1288458000000)/","Returns":"/Date(1289066400000)/","TimeDeparts":null,"TimeReturns":null,"RT":true,"Adults":1,"Seniors":0,"Children":0,"PromoCode":"","DiscountCode":"","Card":"","CardExpiration":"10/2010"}}'
      :body         => request_body
                                    ).body


    agent.request_headers = {
      'Host'=>'www.greyhound.com' ,
      'User-Agent'=>'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10' ,
      'Accept'=>'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' ,
      'Accept-Language'=>'en-us,en;q=0.5' ,
      'Accept-Encoding'=>'gzip,deflate' ,
      'Accept-Charset'=>'ISO-8859-1,utf-8;q=0.7,*;q=0.7' ,
      'Keep-Alive'=>'115' ,
      'Connection'=>'keep-alive',
      'Cookie'=>"ASP.NET_SessionId=#{agent.cookies.first.value}",
    }
    agent.get('https://www.greyhound.com/farefinder/step2.aspx')

    agent.page.body.scan(/\$(\d{2,4}.\d{2})/).flatten.collect(&:to_i).min

  end
end


