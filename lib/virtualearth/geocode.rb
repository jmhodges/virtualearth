module VirtualEarth
  class Geocode < Handsoap::Service
    endpoint(:version => 1,
      :uri => 'http://dev.virtualearth.net/webservices/v1/geocodeservice/geocodeservice.svc')
    GEOCODE_URL = 'http://dev.virtualearth.net/webservices/v1/geocode/contracts/IGeocodeService/'

    def geocode(ve_token, opts={})
      resp = ve_invoke('Geocode') do |msg|
        msg.add('con:request') do |req|
          req.add('com:Credentials') do |cred|
            cred.add('com:Token', ve_token)
          end
          req.add('geo:Query', opts[:query])
        end
      end
      parse_geocode_results(resp)
    end

    def parse_geocode_results(xml)
      res = xml.xpath('//b:GeocodeResult', ns)[0].native_element
      {
        :results => parse_results(res.xpath('//a:Results//b:GeocodeResult', ns))
      }
    end

    def parse_results(geocode_results)
      geocode_results.map do |gr|
        {
          :address      => parse_address(gr.at("//b:Address", ns)),
          :best_view    => parse_best_views(gr.at("//b:BestView", ns)),
          :confidence   => gr.at("//b:Confidence", ns).inner_text,
          :display_name => gr.at("//b:DisplayName", ns).inner_text,
          :entity_type  => gr.at("//b:EntityType", ns).inner_text,
          :locations    => parse_geo_locations(gr.xpath("//b:Locations//b:GeocodeLocation", ns)),
          :match_codes  => parse_match_codes(gr.xpath("//b:MatchCodes", ns))
        }
      end
    end

    def parse_address(address)
      {
        :address_line       => address.at("//b:AddressLine", ns).inner_text,
        :admin_district     => address.at("//b:AdminDistrict", ns).inner_text,
        :country_region     => address.at("//b:CountryRegion", ns).inner_text,
        :district           => address.at("//b:District", ns).inner_text,
        :formatted_address  => address.at("//b:FormattedAddress", ns).inner_text,
        :locality           => address.at("//b:Locality", ns).inner_text,
        :postal_code        => address.at("//b:PostalCode", ns).inner_text,
        :postal_town        => address.at("//b:PostalTown", ns).inner_text,
      }
    end

    def parse_best_views(views)
      {
        :northeast => parse_best_view(views.at("//b:Northeast", ns)),
        :southwest => parse_best_view(views.at("//b:Southwest", ns))
      }
    end

    def parse_best_view(view)
      {
        :altitude   => view.at("//b:Altitude", ns).inner_text,
        :latitude   => view.at("//b:Latitude", ns).inner_text,
        :longitude  => view.at("//b:Longitude", ns).inner_text
      }
    end

    def parse_geo_locations(locations)
      locations.map do |location|
        {
          :altitude             => location.at("//b:Altitude", ns).inner_text,
          :latitude             => location.at("//b:Latitude", ns).inner_text,
          :longitude            => location.at("//b:Longitude", ns).inner_text,
          :calculation_method   => location.at("//b:CalculationMethod", ns).inner_text
        }
      end
    end

    def parse_match_codes(codes)
      codes.map{ |code| code.inner_text }
    end

    def ve_invoke(operation_name, &blk)
      operation_url = GEOCODE_URL + operation_name
      invoke('con:'+operation_name, :soap_action => operation_url, &blk)
    end

    def ns
      {
        'a' => 'http://dev.virtualearth.net/webservices/v1/geocode',
        'b' => 'http://dev.virtualearth.net/webservices/v1/common',
        'c' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
        'd' => 'http://dev.virtualearth.net/webservices/v1/geocode/contracts'
      }
    end

    def on_create_document(doc)
      doc.alias 'con', "http://dev.virtualearth.net/webservices/v1/geocode/contracts"
      doc.alias 'com', 'http://dev.virtualearth.net/webservices/v1/common'
      doc.alias 'geo', 'http://dev.virtualearth.net/webservices/v1/geocode'
    end
  end
end
