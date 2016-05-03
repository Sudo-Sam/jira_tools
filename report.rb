require 'rubygems'
require 'json'
require 'date'
require 'rest-client'
require 'hashie'

def get_metrics (metric, start_Time, end_Time)
  url_head = "http://usbe-mcse-monitor.prod.usbe-mcse-monitor.services.glb.prod.<>.com/mcse-monitor-app/services/toplevelcheck/"
  rest_url = "#{url_head}#{metric}?start_time=#{start_Time}&end_time=#{end_Time}&dimensionKey=global&core=false"
  resp = RestClient::Request.execute(
  :method => :get,
  :url => URI.encode(rest_url.strip),
  :param =>  "{\"start_time\":\"#{start_Time}\",\"end_time\":\"#{start_Time}\",\"dimensionKey\": \"global\", \"core\":\"false\"}",
  :headers=>
  {
    'WM_CONSUMER.ID'=> '1',
    'WM_QOS.CORRELATION_ID'=> '2323',
    'WM_SVC.ENV'=> 'dummy',
    'WM_SVC.VERSION'=> '1.0.0',
    'WM_SVC.NAME'=> 'dummy',
    'WM_CONSUMER.SOURCE_ID'=> 'dummy',
    'WM_TENANT_ID'=> 'DEFAULt',
    :content_type => 'application/json',
    :accept => 'application/json'
  }
  )
  return resp
end

metrics = [
  ["summary", "Summary"],
  ["responsebreakuptimeseries","Response Times"],
  ["exceptiontimeseries", "Exceptions"],
  ["invalidreqtimeseries", "Invalid requests"],
  ["nopromisetimeseries","No PDD - All Pages"]]

capture_metrics = [
  ["Resp > 200ms", "responsebreakuptimeseries", "R200_500" ],
  ["Resp > 200ms", "responsebreakuptimeseries", "R500_1000" ],
  ["Resp > 200ms","responsebreakuptimeseries", "RGT_1800"],
  ["Resp > 200ms","responsebreakuptimeseries", "R1000_1800"],
  ["Resp > 1000ms","responsebreakuptimeseries", "RGT_1800"],
  ["Resp > 1000ms","responsebreakuptimeseries", "R1000_1800"],
  ["RR Computes", "summary", "metric_grp[1]"],
  ["No Inventory", "nopromisetimeseries","noInventory"],
  ["No TNT", "nopromisetimeseries","noTnt"],
  ["No assignment", "nopromisetimeseries","noOptions"],
  ["Internal error","nopromisetimeseries","internalError"],
  ["Invalid Item error","invalidreqtimeseries","itemId"],
  ["Exceptions", "exceptiontimeseries","totl"]
]

threshold = [
  ["Resp > 200ms", 5, 0,"%"],
  ["Resp > 1000ms",1, 0,"%"],
  ["RR Computes", 0.1, 0,"%"],
  ["No Inventory", 0.5, 0,"%"],
  ["No TNT", 0.5, 0,"%" ],
  ["No assignment", 0.25, 0,"%"],
  ["Internal error",0.25, 0,"%"],
  ["Invalid Item error",0.15, 0,"%"],
  ["Exceptions", 5000, 0,"Count"]
]

end_Time = Time.now.utc - 300
start_Time = end_Time - 900
end_Time = end_Time.strftime('%Y-%m-%d %H:%M:%S')
start_Time = start_Time.strftime('%Y-%m-%d %H:%M:%S')
total_requests=0
html = "<h1>MCSE Lite Hourly report - #{start_Time} - #{end_Time}</h1>"
html << "<table border=1>"
html << "<tr><th>Metric</th><th>Value in</th><th>Threshold</th><th>Value</th></tr>"
html << ""
metrics.each do |metric_val|
  metric= metric_val[0]
  metric_desc=metric_val[1]

  metric_arr = []
  sub_arr = []
  resp = get_metrics(metric,start_Time,end_Time)
  hash = JSON.parse(resp)
  mhashed = Hashie::Mash.new hash
  totl=0
  if metric != "summary" then
    mhashed.each do |a|
      app = ""
      count = 0
      if a.class == Array then
        a.each do |b|
          if b.class == Array
            b.each do |c|
              count = count + c.y
            end
          else
          app = b
          end
        end
      sub_arr = []
      sub_arr.push(metric)
      sub_arr.push(app)
      sub_arr.push(count)
      metric_arr.push(sub_arr)
      end
    end
  else
    hash.each do |x,y|
      sub_arr = []
      sub_arr.push(metric)
      sub_arr.push(x)
      sub_arr.push(y)
      metric_arr.push(sub_arr)
    end
  end
  if metric != "summary" then
    metric_arr.each do |val|
      totl=totl+val[2].to_i
    end
  else
    metric_arr.each do |val|
      if val[1]=="totalRequests" then
      totl=val[2]
      total_requests=val[2]
      end
    end
  end
  metric_arr = metric_arr.sort_by{|z,x,y|x}
  metric_arr.each do |val|
    capture_metrics.each do |alert_val|
      if alert_val[1] == metric and val[1] == alert_val[2] then
        threshold.each do |t_arr|
          if t_arr[0] == alert_val[0] then
            if val[2]==0 then
            t_arr[2] = t_arr[2] + 0
            else
            t_arr[2] = t_arr[2] + ((val[2].to_f/total_requests.to_f)*100).round(2)
            end
          end
        end
      elsif alert_val[1] == metric and alert_val[2] == "totl" then
        threshold.each do |t_arr|
          if t_arr[0] == alert_val[0] then
            if val[2]==0 then
            t_arr[2] = t_arr[2] + 0
            else
            t_arr[2] = t_arr[2] + val[2]
            end
          end
        end
      end
    end
  end
end
threshold.each do |val| 
  if val[1] <= val[2].to_f then
   html << "<tr><td>#{val[0]}</td><td>#{val[3]}</td><td>#{val[1]}</td><td>#{val[2]}</td></tr>"
  end
end
puts html

