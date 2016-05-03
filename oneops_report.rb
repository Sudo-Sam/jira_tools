require 'hashie'
require 'rest-client'

rest_url="http://services.warn.<>.com/noc-service/services/noc/oneops/status.json?env=prod&status=active"
resp = RestClient::Request.execute(
:method => :get,
:url => URI.encode(rest_url.strip)
)
rpt_threshold = ARGV[0]
html = " "
html << "<h1>One Ops Report - #{rpt_threshold}% of the nodes are down</h1>"
html << "<table border=1>"
html << "
        <tr>
        <th>Organization</th>
        <th>Assembly</th>
        <th>Environment</th>
        <th>Platform</th>
        <th>Type</th>
        <th>Unhealthy</th>
        <th>Total</th>
        </tr>"
mhashed = Hashie::Mash.new JSON.parse(resp.to_str)
for i in 0..mhashed.data.count-1
  assembly = mhashed.data[i]
  for j in 0..assembly.envs.count-1
    env = assembly.envs[j]
    for k in 0..env.plats.count-1
      platform = env.plats[k]
      for l in 0..platform.cmps.count-1
        compute= platform.cmps[l]
        if (compute.f.to_f/compute.t.to_f)*100 > rpt_threshold.to_f then
          html << "<tr><td>#{assembly.nspath.split("/")[1]}</td><td>#{assembly.nspath.split("/")[2]}</td><td>#{env.pr}</td><td>#{platform.n}</td><td>#{compute.n}</td><td>#{compute.f}</td><td>#{compute.t}</td></tr>"
        end      end    end  endend
puts html
