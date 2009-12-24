require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "gas_cost" do
    location = Location.new(:city_to => "Raleigh, NC", :city_from => "Chapel Hill, NC", :gas_mileage => 30, :gas_price => 3)
    assert_in_delta 2.486811, location.gas_cost, 0.1
  end
end
