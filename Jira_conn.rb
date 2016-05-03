require 'net/http'
require 'net/https'
require 'rest-open-uri'
require 'wordlist'
print "Enter your user Id : "
username = gets.chomp
print "Enter your password : "
Password = gets.chomp
puts "#{username}", "#{Password}"
uri = URI('https://jirasupport.<>.com/rest/api/2/issue/PIPELINE-12045')
param='{"update": {"components": [{ "add" :{"name": "Payment - 3DS"}}]}}'
Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
  request = Net::HTTP::Get.new uri.request_uri
  request.basic_auth "#{username}", "#{Password}"
  response = http.request request # Net::HTTPResponse object
  puts response
end


