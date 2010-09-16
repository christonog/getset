class Iata < ActiveRecord::Base
  before_validation :create_permalink

  validates_presence_of :iata_city, :iata_code, :iata_city_permalink

  class << self
    def locations_to_param(locations)
      city_from = locations['city_from'].is_a?(Iata) ? locations['city_from'] : find_by_iata_city(locations['city_from'])
      city_to   = locations['city_from'].is_a?(Iata) ? locations['city_to']   : find_by_iata_city(locations['city_to'])
      
      "#{city_from.iata_city_permalink}-to-#{city_to.iata_city_permalink}"
    end

    def locations_from_param(r_location)
      city_from, city_to = r_location.split('-to-')
      city_from = find_by_iata_city_permalink(city_from)
      city_to   = find_by_iata_city_permalink(city_to)

      {"city_to" => city_to.iata_city, "city_from" => city_from.iata_city}
    end

    def sitemap_locations
      origins      = all
      destinations = all
      out = []
      origins.each do |o|
        destinations.each do |d|
          out << locations_to_param({'city_from' => o, 'city_to' => d}) if o.id != d.id
        end
      end
      out
    end
  end

  private

  def create_permalink
    self.iata_city_permalink = iata_city.gsub(/[^a-z0-9]+/i, '-')
  end
end

