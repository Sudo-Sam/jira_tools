
  json =  JSON.parse(resp.to_str)
  File.open(ARGV[1], 'w') do |f|
    headers = []
    json.each do |data|
      header = getheaders("",data,"")
      header = header[0..-2] if header[-1,1] == ","
      headers = (headers + header.split(",")).uniq
    end
    f.puts headers.join(",")
    json.each do |data|
      f.puts tocsv(data,headers)
    end
  end
else
  puts "Usage : json2csv <<input file>> <<output file>>"
end