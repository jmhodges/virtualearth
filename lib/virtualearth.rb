require 'handsoap'
require 'digest/md5'
require 'uri'
require 'cgi'

require 'virtualearth/digest_auth'
require 'virtualearth/service'
require 'virtualearth/imagery'
module VirtualEarth
  VERSION = '0.1.0'
  class << self
    attr_accessor :username, :password
  end
end
