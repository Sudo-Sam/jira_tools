require 'pp'
require 'jira'
require 'rubygems'
require 'uri'

uri = URI('https://jirasupport.<>.com/rest/api/2/issue/PIPELINE-12045')
options = {
            :username => 'skumar5',
            :password => 'Jan-2015',
            :site     => uri.host,
            :context_path => '',
            :auth_type => :basic,
            :use_ssl => true,
            :ssl_verify_mode => 'OpenSSL::SSL::VERIFY_NONE'
          }

client = JIRA::Client.new(options)
projects = client.Project.all

projects.each do |project|
  puts "Project -> key: #{project.key}, name: #{project.name}"
end