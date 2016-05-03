require 'json'
require 'base64'
require 'rest-client'
require 'rubygems'
require 'hashie'
require 'mysql2'

def get_key_data(username, password, jql)
  param = "{\"jql\":\"#{jql}\",\"fields\":[\"key\",\"Response time SLA\"],\"maxResults\": 1000}"
  uri = 'https://jirasupport.<>.com/rest/api/2/search'
  resp = RestClient::Request.execute(
  :method => :post,
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
  return resp
end

########################################################

username = "skumar5"
Password = "Mar-2015"
strtDate="2015-05-01 00:00" 
endDate="2015-05-15 23:59"


jira_data = "(created >= 2014-07-01 AND ( (createdDate >= '#{strtDate}' AND createdDate <= '#{endDate}' ) OR  (resolved >= '#{strtDate}' AND resolved <= '#{endDate}')  OR (status != Done AND createdDate <= '#{strtDate}' ))AND (assignee was in membersOf('GeC atSupport - Java Team') OR assignee was in membersOf('GeC @Support - CA') OR assignee was in membersOf('GeC @Support - Front End') OR assignee was in membersOf('GeC @Support - IMS'))) OR ( createdDate >= '#{strtDate}' AND createdDate <= '#{endDate}' AND (reporter in membersOf('GeC atSupport - Java Team') OR assignee was in membersOf('GeC @Support - CA') or reporter in membersOf('GeC @Support - Front End') or reporter in membersOf('GeC @Support - IMS'))) and project not in(ATSRCA,PBL)"
puts jira_data
jira_key = get_key_data("#{username}","#{Password}","#{jira_data}")
jira_key.gsub! 'key','ticket'

key_json = JSON.parse(jira_key.to_str)
key_mhashed = Hashie::Mash.new key_json
puts key_mhashed
