require 'nokogiri'
require 'rest-client'

errors_arr = []
exclude_arr = []
html = "<h1>Nagios Health</h1>"
html << "<table border=1>"
html << "<tr>
        <th>Alert Name</th>
        <th>HOST</th>
        <th>Nagios Link</th>
        </tr>"
url = File.open('/home/atsupport_user/nagios_alert_report/nagios_url.txt')
url.each_line do |rest_url|
  resp = RestClient::Request.execute(
  :method => :get,
  :url => URI.encode(rest_url.strip),
  :user => "noc" ,
  :password => "noc"
  )
  doc = Nokogiri::HTML(resp)
  stat_table = doc.css('html')
  stat_table.each do |td_crit|
    temp = td_crit.to_s
    puts '-----------------------'
    temp.each_line do |td_line|
      if td_line.include? "class=\"statusBGCRITICAL\"><a href=\"extinfo.cgi" then
        det_arr = td_line.split("&")
        det_arr[2] = det_arr[2].split(">")[0].gsub! 'amp;service=',''
        det_arr[1] = det_arr[1].gsub! 'amp;host=',''
        sub_arr = []
        sub_arr.push(det_arr[1])
        sub_arr.push(det_arr[2])
        sub_arr.push(rest_url.strip)
        sub_arr.push("Error")
      errors_arr.push(sub_arr)
      end
      if td_line.include? "Notifications for this service have been disabled" then
        det_arr = td_line.split("&")
        det_arr[2] = det_arr[2].split(">")[0].gsub! 'amp;service=',''
        det_arr[1] = det_arr[1].gsub! 'amp;host=',''
        sub_arr = []
        sub_arr.push(det_arr[1])
        sub_arr.push(det_arr[2])
        sub_arr.push(rest_url.strip)
        sub_arr.push("Exclude")
      exclude_arr.push(sub_arr)
      end
    end
  end
end

errors_arr.each do |val|
  exclude = 0
  exclude_arr.each do |ecl_val|
    if ecl_val[1] == val[1] and ecl_val[0] == val[0] and ecl_val[2] == val[2] then
    exclude = 1
    end
  end
  if exclude == 0 then
    url = "http://#{val[2].split('/')[2].strip}/nagios/cgi-bin/extinfo.cgi?type=2&host=#{val[0]}&service=#{val[1]}"
    html << "<tr><td>#{val[1]}</td><td>#{val[0]}</td><td><a href = \"#{url}\">Click</a></td></tr>"
  end
end
html << "</table>"
puts html
