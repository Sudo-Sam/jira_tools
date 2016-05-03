require 'json'
require 'base64'
require 'rest-client'
require 'rubygems'
require 'hashie'
require 'mysql2'

class Ticket_Data
  def initialize(key)
    @key=key
  end
  def clean_special_chars(variable)
    variable.gsub! '[',''     # remove array start
    variable.gsub! ']',''     # remove array end
    variable.gsub! '\\\\"',"" # Remove \" 
    variable.gsub! "\\",''    # Remove \
    variable.gsub! '"',''     # Remove "
    return variable
  end
end

class Ticket_Record < Ticket_Data
  def initialize(key,  created,  resolved,  summary,  issuetype,  reporter,  assignee,  priority,  status,  environment,  components,  labels, resolution,  issue_category, website)
    super(key)
    @created=clean_special_chars(created)
    @resolved=clean_special_chars(resolved)
    @summary=clean_special_chars(summary)
    @issuetype=clean_special_chars(issuetype)
    @reporter=clean_special_chars(reporter)
    @assignee=clean_special_chars(assignee)
    @priority=clean_special_chars(priority)
    @status=clean_special_chars(status)
    @environment=clean_special_chars(environment)
    @components=clean_special_chars(components)
    @labels=clean_special_chars(labels)
    @resolution=clean_special_chars(resolution)
    @issue_category=clean_special_chars(issue_category)
    @website=clean_special_chars(website)
  end
  def save
    client = Mysql2::Client.new(:host => "172.29.177.195", :username => "root",:password => "Support" , :database=>"jira_report")
    insert_qry = "insert into ticket_data values(\"#{@key}\",\"#{@created}\",\"#{@resolved}\",\"#{@summary}\",\"#{@issuetype}\",\"#{@reporter}\",\"#{@assignee}\",\"#{@priority}\",\"#{@status}\",\"#{@environment}\",\"#{@components}\",\"#{@labels}\",\"#{@resolution}\",\"#{@issue_category}\",\"#{@website}\")
            on duplicate key UPDATE 
            ticket = values(ticket),
            created = values(created),
            resolved = values(resolved),
            summary = values(summary),
            issue_type = values(issue_type),
            reporter = values(reporter),
            assignee = values(assignee),
            priority = values(priority),
            status = values(status),
            environment = values(environment),
            components = values(components),
            labels = values(labels),
            resolution = values(resolution),
            issue_category = values(issue_category),
            website = values(website)
"
    client.query(insert_qry)
    client.close
  end
end
class Work_log < Ticket_Data
  def initialize(key, id, started,  assignee,  time_in_sec)
    super(key)
    @started=clean_special_chars(started)
    @assignee=clean_special_chars(assignee)
    @id=id
    @time_in_sec=time_in_sec
  end
  def save
    client = Mysql2::Client.new(:host => "172.29.177.195", :username => "root",:password => "Support" , :database=>"jira_report")
    insert_qry = "insert into work_log_data values(\"#{@key}\",\"#{@id}\",\"#{@started}\",\"#{@assignee}\",\"#{@time_in_sec}\") 
    on duplicate key update ticket = values(ticket), id= values(id), started = values(started), assignee = values(assignee), time_in_sec = values(time_in_sec)"
    client.query(insert_qry)
    client.close
  end
end
class Assignee_History < Ticket_Data
  def initialize(key,id,  created, from, to)
    super(key)
    @created=clean_special_chars(created)
    @fromid=clean_special_chars(from)
    @toid=clean_special_chars(to)
    @id=id
  end
  def save
    client = Mysql2::Client.new(:host => "172.29.177.195", :username => "root",:password => "Support" , :database=>"jira_report")
    insert_qry = "insert into assignee_history values(\"#{@key}\",\"#{@id}\",\"#{@created}\",\"#{@fromid}\",\"#{@toid}\")
        on duplicate key update
        ticket = values(ticket),
        id = values(id),
        created = values(created),
        from_id = values(from_id),
        to_id = values(to_id)"
    client.query(insert_qry)
    client.close
  end
end
class Change_History < Ticket_Data
  def initialize(key, id, created, from, to, change_type,author)
    super(key)
    @created=clean_special_chars(created)
    @fromid=clean_special_chars(from)
    @toid=clean_special_chars(to)
    @change_type=clean_special_chars(change_type)
    @author=clean_special_chars(author)
    @id=id
  end
  def save
    client = Mysql2::Client.new(:host => "172.29.177.195", :username => "root",:password => "Support" , :database=>"jira_report")
    if @toid.include? '"' then
    insert_qry = "insert into change_history values(\"#{@key}\",\"#{@id}\", \"#{@created}\",\"#{@fromid}\",\"#{@toid.gsub!('"','\\\\"')}\",\"#{@change_type}\",\"#{@author}\")
        on duplicate key update
        ticket = values(ticket),
        id=values(id),
        created = values(created),
        from_string = values(from_string),
        to_string = values(to_string),
        activity_type = values(activity_type),
        author = values(author)"
    else
      insert_qry = "insert into change_history values(\"#{@key}\",\"#{@id}\",\"#{@created}\",\"#{@fromid}\",\"#{@toid}\",\"#{@change_type}\",\"#{@author}\")
        on duplicate key update
        ticket = values(ticket),
        id=values(id),
        created = values(created),
        from_string = values(from_string),
        to_string = values(to_string),
        activity_type = values(activity_type),
        author = values(author)"
    end
    client.query(insert_qry)
    client.close
  end
end
class Comment_log < Ticket_Data
  def initialize(key, id, author, comment, created)
    super(key)
    @created=clean_special_chars(created)
    @author=clean_special_chars(author)
    @comment=clean_special_chars(comment)
    @id=id
  end
  def save
    client = Mysql2::Client.new(:host => "172.29.177.195", :username => "root",:password => "Support" , :database=>"jira_report")
    mentions=get_mentions(@comment)
    if @comment.include? '"' then
      insert_qry = "insert into ticket_comments values(\"#{@key}\",\"#{@id}\",\"#{@author}\",\"#{@comment.gsub!('"','\\\\"')}\",\"#{@created}\",\"#{mentions}\")
          on duplicate key update 
          ticket = values(ticket),
          id= values(id),
          author = values(author),
          comment = values(comment),
          created = values(created),
          mentions = values(mentions)"
    else
      insert_qry = "insert into ticket_comments values(\"#{@key}\",\"#{@id}\",\"#{@author}\",\"#{@comment}\",\"#{@created}\",\"#{mentions}\")
          on duplicate key update 
          ticket = values(ticket),
          id= values(id),
          author = values(author),
          comment = values(comment),
          created = values(created),
          mentions = values(mentions)"
    end
    client.query(insert_qry)
    client.close
    rescue 
      puts 'exception happened'
      end
end

class Sla_log < Ticket_Data
  def initialize(key, resp_sla, reso_sla)
    super(key)
    @resp_sla=clean_special_chars(resp_sla)
    @reso_sla=clean_special_chars(reso_sla)
  end
  def save
    client = Mysql2::Client.new(:host => "172.29.177.195", :username => "root",:password => "Support" , :database=>"jira_report")
      insert_qry = "insert into SLA_Data values(\"#{@key}\",\"#{@resp_sla}\",\"#{@reso_sla}\")
          on duplicate key update 
          ticket = values(ticket),
          Response_SLA_Missed= values(Response_SLA_Missed),
          Resolution_SLA_Missed = values(Resolution_SLA_Missed)"
    puts insert_qry
    client.query(insert_qry)
    client.close
    rescue 
      puts 'exception happened'
      end
end
########################################################

def get_key_data(username, password, jql)
  param = "{\"jql\":\"#{jql}\",\"fields\":[\"key\"],\"maxResults\": 1000}"
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
########################################################
def get_resp_sla(username, password, key)
  jql = "key=#{key} and ('Response SLA' = breached() or 'Response time SLA' = breached())"
  param = "{\"jql\":\"#{jql}\",\"fields\":[\"key\"],\"maxResults\": 1000}"
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
  json =  JSON.parse(resp.to_str)
  mhased = Hashie::Mash.new json
  if mhased.total != 0 then
     return "Y"
  else 
    return "N"
  end
end
########################################################
def get_reso_sla(username, password, key)
  jql = "key=#{key} and ('Resolution SLA' = breached() or 'Resolution Time' = breached() or 'Resolution time' = breached() or 'Resolution time SLA' = breached())"
  param = "{\"jql\":\"#{jql}\",\"fields\":[\"key\"],\"maxResults\": 1000}"
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
  json =  JSON.parse(resp.to_str)
  mhased = Hashie::Mash.new json
  if mhased.total != 0 then
     return "Y"
  else 
    return "N"
  end
end
########################################################
 def get_mentions(text)
    mentions=""
    positions= text.enum_for(:scan, /\~/).map { Regexp.last_match.begin(0) }
    positions.each do |index|
      temp=text[index..text.length]
      temp1=temp.split{/\W+/}
      temp1.each do |temp2|
        mentions << temp2
        break
      end
    end
    return mentions.gsub "\~",""
  end


username = "skumar5"
Password = "Ss54321"
strtDate=ARGV[0]
endDate=ARGV[1]

jira_data = "key in ('INC-85360','INC-85358','INC-85351','INC-85348','INC-85343','INC-85318','INC-85304','INC-85299','INC-85114','INC-85093','INC-84984','INC-84956','INC-84857','INC-84753','INC-84429','INC-84158','INC-84139','INC-83915','INC-83767','INC-83459','INC-83113','CABIZS-1365','CABIZS-1343','CABIZS-1330','CABIZS-1318','ATSUPPORT-42409','ATSUPPORT-42371','ATSUPPORT-42344','ATSUPPORT-42315','ATSUPPORT-42314','ATSUPPORT-42312','ATSUPPORT-41879','ATSUPPORT-41512','ATSUPPORT-41414','ATSUPPORT-41366','ATSUPPORT-41345','ATSUPPORT-41308','ATSUPPORT-41289','ATSUPPORT-41236','ATSUPPORT-41170','INC-91019','INC-91008','INC-90936','INC-90882','INC-90880','INC-90767','INC-90608','INC-90433','INC-90356','INC-90178','INC-90163','INC-90087','INC-89942','CABIZS-1450','ATSUPPORT-45258','ATSUPPORT-45238','ATSUPPORT-45237','ATSUPPORT-45235','ATSUPPORT-45231','ATSUPPORT-45230','ATSUPPORT-45205','ATSUPPORT-45197','ATSUPPORT-45196','ATSUPPORT-45189','ATSUPPORT-45158','ATSUPPORT-45077','SAMSHD-31942','INC-89878','INC-89839','INC-89837','INC-89646','INC-89636','INC-89570','INC-89511','INC-89272','INC-88791','INC-88660','INC-88606','INC-88605','INC-88526','INC-88324','INC-87851','DEMOS-74','CABIZS-1437','CABIZS-1424','ATSUPPORT-44675','ATSUPPORT-44484','ATSUPPORT-44477','ATSUPPORT-44449','ATSUPPORT-44343','ATSUPPORT-44342','ATSUPPORT-44341','ATSUPPORT-44311','ATSUPPORT-44164','ATSUPPORT-44148','ATSUPPORT-44147','ATSUPPORT-44133','ATSUPPORT-44128','ATSUPPORT-44114','ATSUPPORT-44107','ATSUPPORT-43972','ATSUPPORT-43915','ATSUPPORT-43913','ATSUPPORT-43890','ATSUPPORT-43859','ATSUPPORT-43827','ATSUPPORT-43826','ATSUPPORT-43794','ATSUPPORT-43755','ATSUPPORT-43614','ATSUPPORT-43612','ATSUPPORT-43559','ATSUPPORT-43544','ATSUPPORT-43530','ATSUPPORT-43524','ATSUPPORT-43521','ATSUPPORT-43520','ATSUPPORT-43516','SAMSHD-31791','INC-87775','INC-87422','INC-87394','INC-87336','INC-87239','INC-87141','INC-87082','INC-86948','INC-86930','INC-86780','INC-86732','INC-86699','INC-86348','INC-86343','INC-86326','INC-86309','INC-86123','INC-86117','INC-86107','INC-85939','INC-85861','INC-85813','INC-85775','ATSUPPORT-43479','ATSUPPORT-43462','ATSUPPORT-43309','ATSUPPORT-43272','ATSUPPORT-43140','ATSUPPORT-42989','ATSUPPORT-42926','ATSUPPORT-42919','ATSUPPORT-42868','ATSUPPORT-42860','ATSUPPORT-42859','ATSUPPORT-42856','ATSUPPORT-42847','ATSUPPORT-42846','ATSUPPORT-42711','ATSUPPORT-42630','ATSUPPORT-42555','ATSUPPORT-42526','ATSUPPORT-42504','ATSUPPORT-42497','ATSUPPORT-42456','ATSUPPORT-42454','INC-88492','ATSUPPORT-45276','ATSUPPORT-45211','ATSUPPORT-45151','ATSUPPORT-45150','ATSUPPORT-45090','ATSUPPORT-45012','ATSUPPORT-45011','ATSUPPORT-45010','ATSUPPORT-44946','ATSUPPORT-44336')"
#jira_data = "((created >= '2016-02-01 00:00' AND ((createdDate >= '#{strtDate}' AND createdDate <= '#{endDate}') OR (resolved >= '#{strtDate}' AND resolved <= '#{endDate}') OR (status != Done AND createdDate <= '#{strtDate}' ) ) AND ( assignee was in membersOf('GeC @support - Jira Users') OR assignee was in (srattan, snagend, avishak, sbalak6, mrajase, agupt29, vsingh5, sqadri, smahabu, droyala, ukumar, aaski, lganjam, vdilli, pgupta7, praghu1, pvelhal, dbalas1, mdas7, sdas19, ksatyan, skar1, rbehera, crallap, mbalagu, vkataba, mramanj, iuppu, bebanez, ranton6, ssiddes, srajpu1, gjosep2, asrini2, panand2, nshukl1, kmanyam, sgera, skethep, kpalla, kpriya, achauh1, asinha6) ) ) OR ( createdDate >= '#{strtDate}' AND createdDate <= '#{endDate}'AND ( reporter in membersOf('GeC @support - Jira Users') OR reporter was in (srattan, snagend, avishak, sbalak6, mrajase, agupt29, vsingh5, sqadri, smahabu, droyala, ukumar, aaski, lganjam, vdilli, pgupta7, praghu1, pvelhal, dbalas1, mdas7, sdas19, ksatyan, skar1, rbehera, crallap, mbalagu, vkataba, mramanj, iuppu, bebanez, ranton6, ssiddes, srajpu1, gjosep2, asrini2, panand2, nshukl1, kmanyam, sgera, skethep, kpalla, kpriya, achauh1, asinha6) ) ) ) and project not in(ATSRCA,PBL) and website != 'US GM'"
#jira_data = "(created >= 2016-02-01 AND ( (createdDate >= '#{strtDate}' AND createdDate <= '#{endDate}' ) OR  (resolved >= '#{strtDate}' AND resolved <= '#{endDate}')  OR (status != Done AND createdDate <= '#{strtDate}' ))AND (assignee was in membersOf('GeC @support - Jira Users') OR assignee was in membersOf('GeC @Support - CA') OR assignee was in membersOf('GeC @Support - Front End') OR assignee was in membersOf('GeC @Support - IMS'))) OR ( createdDate >= '#{strtDate}' AND createdDate <= '#{endDate}' AND (reporter in membersOf('GeC atSupport - Java Team') OR assignee was in membersOf('GeC @Support - CA') or reporter in membersOf('GeC @Support - Front End') or reporter in membersOf('GeC @Support - IMS'))) and project not in(ATSRCA,PBL)"
puts jira_data
jira_key = get_key_data("#{username}","#{Password}","#{jira_data}")
jira_key.gsub! 'key','ticket'

key_json = JSON.parse(jira_key.to_str)
key_mhashed = Hashie::Mash.new key_json

for i in 0..key_mhashed.issues.count-1
  key = key_mhashed.issues[i].ticket
  resp = get_ticket_details("#{username}","#{Password}","#{key}")
  resp_sla = get_resp_sla("#{username}","#{Password}","#{key}")
  reso_sla = get_reso_sla("#{username}","#{Password}","#{key}")
  json =  JSON.parse(resp.to_str)
  mhased = Hashie::Mash.new json
  
  sla_rec = Sla_log.new("#{key}","#{resp_sla}","#{reso_sla}")
  sla_rec.save
  
  if mhased.fields.key?('customfield_10701') and mhased.fields.customfield_10701 != nil then
      mhased.fields.customfield_10701 = mhased.fields.customfield_10701.value
  else
    mhased.fields.customfield_10701 = "Issue"
  end
  
  if mhased.fields.key?('customfield_10212') and mhased.fields.customfield_10212 != nil then
    if mhased.fields.customfield_10212.key?('value') then
      mhased.fields.customfield_10212 = mhased.fields.customfield_10212.value
    end
  else
    mhased.fields.customfield_10212 = "None"
  end
  if mhased.fields.key?('customfield_14500') and mhased.fields.customfield_14500 != nil then
    if mhased.fields.customfield_14500[0].key?('value') then
      mhased.fields.customfield_14500 = mhased.fields.customfield_14500[0].value
    end
  else
    mhased.fields.customfield_14500 = "None"
  end  
  
  if mhased.fields.key?('components') and mhased.fields.components != nil then
    if mhased.fields.components.count > 0 then
      mhased.fields.components = mhased.fields.components[0].name
    end
  else
    mhased.fields.components = "None"
  end


  if mhased.fields.key?('priority') and mhased.fields.priority != nil then
    if mhased.fields.priority.key?('name') then
      priority = mhased.fields.priority.name
    end
  elsif mhased.fields.parent.key?('priority') and mhased.fields.parent.priority != nil then
    if mhased.fields.parent.priority.key?('name') then
      priority= mhased.fields.priority.name
    end
   else    
    priority= "None"
  end
  
  if mhased.fields.key?('resolution') and mhased.fields.resolution != nil then
    if mhased.fields.resolution.key?('name') then
      mhased.fields.resolution = mhased.fields.resolution.name
    end
  else
    mhased.fields.resolution = "None"
  end
  if mhased.fields.key?('assignee') and mhased.fields.assignee != nil then
    if mhased.fields.assignee.key?('displayName') then
      mhased.fields.assignee = mhased.fields.assignee.displayName
    end
  else
    mhased.fields.assignee = 'Unassigned'
  end  

  
  puts key
  ticket_rec = Ticket_Record.new("#{key}",  "#{mhased.fields.created}",  "#{mhased.fields.resolutiondate}",  "#{mhased.fields.summary}",  "#{mhased.fields.issuetype.name}",  "#{mhased.fields.reporter.displayName}",  "#{mhased.fields.assignee}",  "#{priority}",  "#{mhased.fields.status.name}",  "#{mhased.fields.customfield_10212}",  "#{mhased.fields.components}",  "#{mhased.fields.labels}", "#{mhased.fields.resolution}",  "#{mhased.fields.customfield_10701}",  "#{mhased.fields.customfield_14500}")
  ticket_rec.save
  
  mhased.fields.worklog.worklogs.each do |worklog|
    if worklog.started? then
      work_log_rec = Work_log.new("#{key}","#{worklog.id}","#{worklog.started}","#{worklog.author.name}","#{worklog.timeSpentSeconds}")
      work_log_rec.save
    end
  end
  mhased.changelog.histories.each do |history|
    history.items.each do |item|
      if item.field ==  "assignee" then
        assignee_rec = Assignee_History.new("#{key}", "#{history.id}", "#{history.created}","#{item.fromString}","#{item.toString}")
        assignee_rec.save
      else
        change_log_rec = Change_History.new("#{key}", "#{history.id}", "#{history.created}","#{item.fromString}","#{item.toString}", "#{item.field}","#{history.author.displayName}")
        change_log_rec.save
      end
    end
  end
  mhased.fields.comment.comments.each do |comment|
    if comment.created? then
      comment_rec = Comment_log.new("#{key}","#{comment.id}","#{comment.author.displayName}","#{comment.body}","#{comment.created}")
      comment_rec.save
    end
  end
end
