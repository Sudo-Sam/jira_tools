require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'

uri= URI("https://jirasupport.<>.com")
http = Net::HTTP.new(uri.host,uri.port,uri.scheme=>'https')
http.use_ssl = true
http.ca_file = "/c/RailsInstaller/cacert.pem"
http.verify_mode='OpenSSL::SSL::VERIFY_NONE'
http.set_debug_output $stdout
http.start do 
   req = Net::HTTPS::Get.new('/rest/api/2/issue/PIPELINE-12045')
   req.basic_auth 'skumar5', 'Jan-2015'
   req.content_type 'application/json'
   resp, data = http.request(req)
end
