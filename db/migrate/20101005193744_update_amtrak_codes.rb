class UpdateAmtrakCodes < ActiveRecord::Migration
  def self.up

    {
    'Boise, ID' => "BOI",
	  'Columbia, SC' => "CLB",
	  'Charleston, SC' => "CHS",
	  'Wichita, KS' => nil,
	  'Richmond, VA' => "RVM",
	  'North Platte, NE' => nil,
	  'West Palm Beach, FL' => "WPB",
	  'El Paso, TX' => "ELP",
	  'Pensacola, FL' => nil,
	  'Montreal, PQ' => "MTR",
	  'Vancouver, BC' => "VAC",
	  'Toronto, ON' => "TWO",
	  'Ottawa, ON' => nil,
	  'Winnipeg, MB' => nil,
	  "Albany, NY" => "ALB",
    "Albuquerque, NM" => "ABQ",
    "Atlanta, GA" => "ATL",
    "Anchorage, AK" => nil,
    "Austin, TX" => "AUS",
    "Baltimore, MD" => "BWI",
    "Bangor, ME" => "BAN",
    "Baton Rouge, LA" => "BTR",
    "Binghampton, NY" => nil,
    "Birmingham, AL" => "BHM",
    "Boston, MA" => "BOS",
    "Buffalo, NY" => "BUF",
    "Charleston, WV" => "CHW",
    "Charlotte, NC" => "CLT",
    "Chattanooga, TN" => nil,
    "Chicago, IL" => "CHI",
    "Cincinnati, OH" => "CIN",
    "Cleveland, OH" => "CLE",
    "Columbus, OH" => nil,
    "Colorado Springs, CO" => "COS",
    "Dallas, TX" => "DAL",
    "Denver, CO" => "DEN",
    "Des Moines, IA" => nil,
    "Detroit, MI" => "DET",
    "Fayetteville, NC" => "FAY",
    "Ft Lauderdale, FL" => "FTL",
    "Ft Myers, FL" => "FTM",
    "Ft Wayne, IN" => nil,
    "Greensboro, NC" => "GRO",
    "Hartford, CT" => "HFD",
    "Houston, TX - HOU" => "HOS",
    "Indianapolis, IN" => "IND",
    "Ithaca, NY" => nil,
    "Jacksonville, FL" => "JAX",
    "Kansas City, MO" => "KCY",
    "Key West, FL" => nil,
    "Knoxville, TN" => nil,
    "Las Vegas, NV" => "LSV",
    "Los Angeles, CA" => "LAX",
    "Louisville, KY" => "LVL",
    "Manchester, NH" => "MHT",
    "Memphis, TN" => "MEM",
    "Miami, FL" => "MIA",
    "Milwaukee, WI" => "MKE",
    "Minneapolis, MN" => "MSP",
    "Nashville, TN" => nil,
    "New Orleans, LA" => "NOL",
    "New York, NY" => "NYP",
    "Newark, NJ" => "EWR",
    "Oakland, CA" => "OAC",
    "Oklahoma City, OK" => "OKC",
    "Ontario, CA" => "ONA",
    "Omaha, NE" => "OMA",
    "Orlando, FL" => "ORL",
    "Philadelphia, PA" => "PHL",
    "Phoenix, AZ" => "PXN",
    "Pittsburgh, PA" => "PGH",
    "Portland, OR" => "PDX",
    "Portland, ME" => "POR",
    "Providence, RI" => "PVD",
    "Raleigh, NC" => "RGH",
    "Reno, NV" => "RNO",
    "Rochester, NY" => "ROC",
    "Sacramento, CA" => "SAC",
    "Salt Lake City, UT" => "SLC",
    "San Antonio, TX" => "SAS",
    "San Diego, CA" => "SAN",
    "San Francisco, CA" => "SFP",
    "San Jose, CA" => "SJC",
    "Santa Ana, CA" => "SNA",
    "Seattle, WA" => "SEA",
    "St Louis, MO" => "STL",
    "Syracuse, NY" => "SYR",
    "Tampa, FL" => "TPA",
    "Tulsa, OK" => nil ,
    "Washington, DC" => "WAS",
    "White Plains, NY" => nil
    }.each do |city, code|
      printf " -- #{city}"
      location = Iata.find(:first, :conditions=> ["iata_city LIKE ?", city + "%"])
        if location
          sql = ActiveRecord::Base.connection();
          sql.execute "UPDATE iatas SET amtrak_code = '#{code}' WHERE id = #{location.id}"
          printf " => #{code} -- Amtrak\n"
        else
          printf "  ======== NOT FOUND\n"
        end
    end
  end

end
