require "test/unit"
require "mock_soap"
require "virtualearth"

if ENV['cache_mode'] == 'store_new'
  VirtualEarth.username = ENV['username']
  VirtualEarth.password = ENV['password']
  MockSoap.cache_mode = :store_new
end

Handsoap::Service.logger = File.open('foo.txt','w')
MockSoap.cache_dir = File.dirname(__FILE__) + '/data'

class TestVirtualEarth < Test::Unit::TestCase
  
  def mock_soap
    @mock_soap ||= MockSoap.new(
                                :extra_namespaces =>{
                                  'con' => "http://dev.virtualearth.net/webservices/v1/imagery/contracts",
                                  'com' => 'http://dev.virtualearth.net/webservices/v1/common',
                                  'imag' => "http://dev.virtualearth.net/webservices/v1/imagery",
                                  'arr' => "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
                                })
    @mock_soap
  end

  def test_get_map_uri
    # Token gathered from a MapPoint::Common.get_client_token call.
    token = "snhBIno4TU8nenMjwf1isqr2JYjRw3fu_MDNb4EH-6o2zYcK5KccI5fyTOGOR6HGFdYE9_U6-E1ccW6cqovgWQ2"
    mock_soap.for('GetMapUri').
      with_xpath('//imag:Center/com:Latitude/text()' => '34.113033').
      with_xpath('//imag:Center/com:Longitude/text()' => '-118.2685').
      with_xpath('//imag:ZoomLevel/text()' => '3').
      with_xpath('//imag:ImageSize/com:Width/text()' => '200').
      with_xpath('//imag:ImageSize/com:Height/text()' => '250').
      with_xpath('//imag:DisplayLayers/arr:string/text()' => 'TrafficFlow').
      with_xpath('//imag:ImageType/text()' => 'Png').
      with_xpath('//imag:Pushpins/com:Pushpin/com:Location/com:Latitude/text()' => '34.155217').
      with_xpath('//imag:Pushpins/com:Pushpin/com:Location/com:Longitude/text()' => '-118.255463').
      with_xpath('//com:Token/text()' => token)
    
    res = VirtualEarth::Imagery.get_map_uri(token,
                                             :center_latitude => 34.113033,
                                             :center_longitude => -118.2685,
                                             :zoom => 3,
                                             :width => 200,
                                             :height => 250,
                                             :layers => ['TrafficFlow'],
                                             :image_type => 'Png',
                                             :pushpins => [
                                                           latlon(34.155217,-118.255463)
                                                          ]
                                             )
    expected_url = "http://api.tiles.virtualearth.net/api/GetMap.ashx?c=34.113033,-11"\
    "8.2685&ppl=34.155217,-118.255463&w=200&h=250&o=png&b=r,shading"\
    ".hill,mkt.en-US&z=3&token={token}"
    assert_equal expected_url, res[:url]
  end

  def latlon(lat,lon)
    {:latitude => lat, :longitude => lon}
  end
end
