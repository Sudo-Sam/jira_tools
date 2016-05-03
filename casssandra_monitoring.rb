require 'rest-client'
require 'json'
require 'hashie'

def get_cluster_id(ip)
  server = ip.strip
  rest_url = "http://#{server}:8888/cluster-configs"
  resp = RestClient::Request.execute(
  :method => :get,
  :url => URI.encode(rest_url.strip),
  :user => 'opsoper',
  :password => 'opscenteroper'
  )
  return resp
end

def get_bad_nodes(application, server, cluster_id)
  bad_node = []
  rest_url = "http://#{server}:8888/#{cluster_id}/nodes"
  url = "http://#{server}:8888/opscenter/index.html"
  resp = RestClient::Request.execute(
  :method => :get,
  :url => URI.encode(rest_url.strip),
  :user => 'opsoper',
  :password => 'opscenteroper'
  )
  node_json = JSON.parse(resp)
  node_json.each do |key_node|
    if key_node["last_seen"] != 0 then
      bad_node.push("<tr><td>#{application}</td><td>#{url}</td><td>#{key_node['rpc_ip']}</td><td>#{key_node['node_name']}</td><td>#{key_node['dc']}</td><td>#{Time.at(key_node['last_seen'])}</tr>")
    end
  end
  return bad_node
end

html = " "
html << "<h1>Cassandra DB - Health report</h1>"
html << "<table border=1>"
html << "
        <tr>
        <th>Application</th>
        <th>Ops Center URL</th>
        <th>IP Down</th>
        <th>Node Name</th>
        <th>Data Center</th>
        <th>Down Since</th>
        </tr>"
server_list = File.open('cassandra_servers.txt')
server_list.each_line do |server|
  ip=server.split("|")[1].strip
  app = server.split("|")[0].strip
  resp = get_cluster_id(ip)
  cluster_json = JSON.parse(resp)
  cluster_json.keys.each do |cluster|
    bad_cluster = get_bad_nodes(app, ip, cluster.strip)
    for i in 0..bad_cluster.count 
      html << bad_cluster[i].to_s
    end
  end
end
html << "</table>"
puts html
