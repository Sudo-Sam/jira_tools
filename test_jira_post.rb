require 'json'
require 'base64'
require 'rest-client'
require 'rubygems'
require 'hashie'

def update_component (username, password, key, component)
  uri = 'https://jirasupport.<>.com/rest/api/2/issue/'"#{key}"
  param='{"update": {"components": [{ "add" :{"name": "' "#{component}" '"}}]}}'
  resp = RestClient::Request.execute(
  :method => :put,
  :url => uri,
  :payload => param,
  :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
  :user => "#{username}" ,
  :password => "#{password}" ,
  :headers=>
  {
    :content_type => 'application/json',
    :accept => 'application/json'
  }
  )
end

def get_ticket_details (username, password, key)
  uri = 'https://jirasupport.<>.com/rest/api/2/issue/'"#{key}"'?expand=changelog'
  resp = RestClient::Request.execute(
  :method => :get,
  :url => uri,
  :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
  :user => "#{username}" ,
  :password => "#{password}" ,
  :headers=>
  {
    :content_type => 'application/json',
    :accept => 'application/json'
  }
  )
  return resp
end

=begin
print "Enter your user Id : "
username = gets.chomp
print "Enter your password : "
Password = gets.chomp
print "Enter the ticket that you want to modify : "
key=gets.chomp
=end
# resp = get_ticket_details("#{username}","#{Password}","#{key}")
resp = get_ticket_details("skumar5","Jan-2015","PIPELINE-12045")
json =  JSON.parse(resp.to_str)
mhased = Hashie::Mash.new json

puts mhased.fields.summary
puts mhased.fields.created
puts mhased.fields.resolved
puts mhased.fields.issuetype.name
puts mhased.fields.reporter.name
puts mhased.fields.priority.name
puts mhased.fields.status.name
puts mhased.fields.environment
puts mhased.fields.components
puts mhased.fields.resolution
puts mhased.fields.worklog.worklogs[1].started
puts mhased.fields.worklog.worklogs[1].author.name
mhased.fields.worklog.worklogs.each do |worklog|
  puts worklog.started
  puts worklog.author.name
  puts worklog.timeSpentSeconds
end
mhased.changelog.histories.each do |history|
  history.items.each do |item|
    if item.field ==  "labels" then
      puts item.field
      puts item.toString
    end
  end
end

