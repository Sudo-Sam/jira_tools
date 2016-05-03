#!/bin/bash
OWNER=su - app
count = ps -ef | grep SOAP83
if (( count != 0 )) 
then
echo "stopping SOAP83 service"
sh /app/ADP/TaxwareEnterprise/jboss-eap-5.0/jboss-as/server/SOAP83/stoptwesoapapplication.sh

fi
count1= ps -ef | grep TWE83
if (( count == 0 && count1 !=0)) then
echo "SOAP83 service stopped now stopping TWE83 service"
sh cd /app/ADP/TaxwareEnterprise/jboss-eap-5.0/jboss-as/server/TWE83/stoptweapplication.sh
fi
if (( count1 ==0)) then
echo "Starting TWE83 service"
./starttweapplication.sh -c TWE83 -b edc-taxtwe5.prod.><.com &
fi
if (( count1 ==1)) then 
echo "Starting SOAP83 service"
cd /app/ADP/TaxwareEnterprise/jboss-eap-5.0/jboss-as/server/SOAP83
./starttwesoapapplication.sh &
fi 
if (( count == 1 && count1 ==1)) then
exit
