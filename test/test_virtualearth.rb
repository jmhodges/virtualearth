require "test/unit"
require "mock_soap"
require "virtualearth"

if ENV['cache_mode'] == 'store_new'
  MockSoap.cache_mode = :store_new
end

MockSoap.cache_dir = File.dirname(__FILE__) + '/data'
# Handsoap::Service.logger = File.open('foo.txt','w')

class TestVirtualEarth < Test::Unit::TestCase
  
  def mock_soap
    @mock_soap ||= MockSoap.new(
                                :extra_namespaces =>
                                {
                                  'con' => "http://dev.virtualearth.net/webservices/v1/imagery/contracts",
                                  'com' => 'http://dev.virtualearth.net/webservices/v1/common',
                                  'imag' => "http://dev.virtualearth.net/webservices/v1/imagery",
                                  'arr' => "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
                                })
    @mock_soap
  end

  def test_get_map_uri
    # Token gathered from a MapPoint::Common.get_client_token call.
    token = "4udsH2_UT8nFZkM-UknIDbgImuLnt_g5GPKxqrTn3q3QDiyE1vc7sufvV-fOI6z5xc--nAQo5w-JBC6wkg7Z5Q2"
    mock_soap.for('GetMapUri').
      with_xpath('//imag:Center/com:Latitude/text()' => '34.113033').
      with_xpath('//imag:Center/com:Longitude/text()' => '-118.2685').
      with_xpath('//imag:ZoomLevel/text()' => '14').
      with_xpath('//imag:ImageSize/com:Width/text()' => '600').
      with_xpath('//imag:ImageSize/com:Height/text()' => '400').
      with_xpath('//imag:DisplayLayers/arr:string/text()' => 'TrafficFlow').
      with_xpath('//imag:ImageType/text()' => 'Png').
      with_xpath('//imag:Pushpins/com:Pushpin/com:Location/com:Latitude/text()' => '34.113033').
      with_xpath('//imag:Pushpins/com:Pushpin/com:Location/com:Longitude/text()' => '-118.2685').
      with_xpath('//imag:Pushpins/com:Pushpin/com:Label/text()' => '99').
      with_xpath('//imag:Pushpins/com:Pushpin/com:IconStyle/text()' => '2').
      with_xpath('//com:Token/text()' => token).
      with_xpath('//imag:Style/text()' => 'Aerial')
    res = VirtualEarth::Imagery.get_map_uri(token,
                                            :center_latitude => 34.113033,
                                            :center_longitude => -118.2685,
                                            :zoom => 14,
                                            :width => 600,
                                            :height => 400,
                                            :layers => ['TrafficFlow'],
                                            :image_type => 'Png',
                                            :pushpins => [
                                                           pushpin_detail(34.113033,-118.2685, '99', '2'),
                                                          ],
                                            :style => 'Aerial'
                                            )

    expected_uri = "http://api.tiles.virtualearth.net/api/GetMap.ashx?c=34.113033,"\
      "-118.2685&ppl=2,99,34.113033,-118.2685&w=600&h=400&o=png&b=a,mkt.en-US&z=14&token={token}"
    assert_equal expected_uri, res[:uri]
  end

  def pushpin_detail(lat, lon, label, icon_style)
    {:latitude => lat, :longitude => lon, :label => label, :icon_style => icon_style}
  end
end
