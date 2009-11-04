module VirtualEarth
  class Imagery < Handsoap::Service
    endpoint(:uri =>
             'http://dev.virtualearth.net/webservices/v1/imageryservice/imageryservice.svc',
             :version => 1)
    IMAGERY_URL = "http://dev.virtualearth.net/webservices/v1/imagery/contracts/IImageryService/"
    
    def get_map_uri(ve_token,opts={})
      resp = ve_invoke('GetMapUri') do |msg|
        msg.add('con:request') do |req|
          req.add('com:Credentials') do |cred|
            cred.add('com:Token', ve_token)
          end

          req.add('imag:Center') do |center|
            center.add('com:Latitude', opts[:center_latitude]) if opts[:center_latitude]
            center.add('com:Longitude', opts[:center_longitude]) if opts[:center_longitude]
          end

          req.add('imag:Options') do |io|
            if opts[:height] && opts[:width]
              io.add('imag:ImageSize') do |is|
                is.add('com:Height', opts[:height])
                is.add('com:Width', opts[:width])
              end
            end

            io.add('imag:ImageType', opts[:image_type]) if opts[:image_type]
            io.add('imag:ZoomLevel', opts[:zoom]) if opts[:zoom]
            io.add('imag:Style', opts[:style]) if opts[:style]
            if opts[:layers]
              io.add('imag:DisplayLayers') do |dl|
                opts[:layers].each{|layer| dl.add('arr:string', layer) }
              end
            end
          end

          add_pushpins(req, opts[:pushpins])
        end
      end

      parse_map_uri(resp.native_element.document)
    end

    def add_pushpins(xml, pushpins)
      return unless pushpins
      xml.add('imag:Pushpins') do |pps|
        pushpins.each do |pin|
          pps.add('com:Pushpin') do |pp|
            pp.add('com:IconStyle', pin[:icon_style]) if pin[:icon_style]
            pp.add('com:Label', pin[:label]) if pin[:label]
            if pin[:latitude] && pin[:longitude]
              pp.add('com:Location') do |loc|
                loc.add('com:Latitude', pin[:latitude])
                loc.add('com:Longitude', pin[:longitude])
              end
            end
          end
        end
      end
    end

    def parse_map_uri(xml)
      { :uri => xml.
        xpath('//a:Uri[1]',
              'a' => "http://dev.virtualearth.net/webservices/v1/imagery").
        inner_text
      }
    end

    def ve_invoke(operation_name, &blk)
      operation_url = IMAGERY_URL + operation_name
      invoke('con:'+operation_name, :soap_action => operation_url, &blk)
    end

    def on_create_document(doc)
      doc.alias 'con', "http://dev.virtualearth.net/webservices/v1/imagery/contracts"
      doc.alias 'com', 'http://dev.virtualearth.net/webservices/v1/common'
      doc.alias 'imag', "http://dev.virtualearth.net/webservices/v1/imagery"
      doc.alias 'arr', "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
    end
  end
end
