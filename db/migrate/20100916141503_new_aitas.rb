class NewAitas < ActiveRecord::Migration
  def self.up
    {
      'Boise, ID' => "BOI",
      'Columbia, SC' => "CAE",
      'Charleston, SC' => "CHS",
      'Wichita, KS' => "ICT",
      'Richmond, VA' => "RIC",
      'North Platte, NE' => "LBF",
      'West Palm Beach, FL' => "PBI",
      'El Paso, TX' => "ELP",
      'Pensacola, FL' => "PNS",
      'Montreal, PQ' => "YUL",
      'Vancouver, BC' => "YVR",
      'Toronto, ON' => "YYZ",
      'Ottawa, ON' => "YOW",
      'Winnipeg, MB' => "YWG"
    }.each do |city, code|
      Iata.create! :iata_city => city, :iata_code => code
    end
  end

  def self.down
  end
end
