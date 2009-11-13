require "test/unit"
require "mock_soap"
require "virtualearth"
require "handsoap"

if ENV['cache_mode'] == 'store_new'
  MockSoap.cache_mode = :store_new
end

MockSoap.cache_dir = File.dirname(__FILE__) + '/data'

class TestGeocode < Test::Unit::TestCase
  def mock_soap
    @mock_soap ||= MockSoap.new(
      :extra_namespaces => {
        'a' => 'http://dev.virtualearth.net/webservices/v1/geocode',
        'b' => 'http://dev.virtualearth.net/webservices/v1/common',
        'c' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
        'd' => 'http://dev.virtualearth.net/webservices/v1/geocode/contracts'
      })
    @mock_soap
  end

  def test_geocode
    query = '611 N Brand Ave Glendale CA'
    token = 'XMm2zqPUObVgFXXgAsJ3MvdwlVA8Lt-ieJpHgfMC9hKioouiefmv5lLi4YLo76aUPiK4yrNjS68S1dt9M5w7UA2'
    mock_soap.for('Geocode').
      with_xpath('//b:Token/text()' => token).with_xpath('//a:Query/text()' => query)
    res = VirtualEarth::Geocode.geocode(token, :query => query)[:results].first
    assert_equal res[:display_name], "611 N Brand Blvd, Glendale, CA 91203-1221"
    assert_equal res[:address][:locality], "Glendale"
    assert_equal res[:address][:address_line], "611 N Brand Blvd"
    assert_equal res[:address][:postal_code], "91203-1221"
    assert_equal res[:address][:admin_district], "CA"
    assert_equal res[:address][:postal_town], ""
    assert_equal res[:address][:country_region], "United States"
    assert_equal res[:address][:district], ""
    assert_equal res[:address][:formatted_address], "611 N Brand Blvd, Glendale, CA 91203-1221"
    assert_equal res[:entity_type], "Address"
    assert_equal res[:best_view][:southwest][:latitude], "34.158987717570675"
    assert_equal res[:best_view][:southwest][:longitude], "-118.25049952370165"
    assert_equal res[:best_view][:southwest][:altitude], "0"
    assert_equal res[:best_view][:northeast][:latitude], "34.158987717570675"
    assert_equal res[:best_view][:northeast][:longitude], "-118.25049952370165"
    assert_equal res[:best_view][:northeast][:altitude], "0"
    assert_equal res[:match_codes], ['Good']
    assert_equal res[:confidence], "High"
    loc = res[:locations].first
    assert_equal loc[:longitude], "-118.25049952370165"
    assert_equal loc[:altitude], "0"
    assert_equal loc[:calculation_method], "Rooftop"
    assert_equal loc[:latitude], "34.158987717570675"
  end
end
