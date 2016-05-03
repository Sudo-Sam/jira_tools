require 'json'
require 'hashie'
file_json = File.read('Postman.json')
json_parse = JSON.parse(file_json)
i=0
json_parse["collections"].each do |temp|
  i=i+1
  File.open("#{i}.json", 'w') { |file| file.write("#{temp}.to_json") }
end