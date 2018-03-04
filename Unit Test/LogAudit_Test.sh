# ===============================================================================================================================
# Descriptiopn : Script to enable auditing and expand audit logs 
# Author       : Selvaraaju Murugesan
# Date         : 18/09/2017
# Authorsed by :
# Last Modified: 16/10/2017
# Audi Log     : Added new code for some audit operations
# ===============================================================================================================================


#Some basic information about the cluster
clear

#create expandaudit directory and set permissions
hadoop fs -mkdir /myexpandedauditlogs
hadoop fs -chgrp domain_users /myexpandedauditlogs
hadoop fs -chmod 755 /myexpandedauditlogs

#Auditing on
hadoop mfs -setaudit on /Data/CMTEDD
hadoop mfs -setaudit on /Data/TCCS

#----------------------------------------------------------------------------------

read -rsp $'Now perform some operations on the volume CMTEDD and TCCS...' -n1 key

#----------------------------------------------------------------------------------

echo 'Performing some scheduled operations on volumes....'
hadoop fs -copyfromLocal Cyclist_Crashes.csv /Data/TCCS
hadoop fs -copyfromLocal Busdata_BEL.txt /Data/TCCS
hadoop fs -copyfromLocal Busdata_CBR.txt /Data/TCCS
hadoop fs -copyfromLocal Busdata_WDN.txt /Data/TCCS
hadoop fs -cat /Data/TCCS/Busdata_WDN.txt
hadoop fs -chgrp 777 /Data/TCCS/Busdata_BEL.txt
hadoop fs -ls /Data/CMTEDD
hadoop fs -touchz /Data/CMTEDD/sample.txt
hadoop fs -chmod 777 /Data/CMTEDD/sample.txt
haddop fs -ls /data/TCCS

#Expand audits for few volumens
/opt/mapr/bin/expandaudit -cluster mapr.test.act.gov.au -volumename CMTEDD -o /mapr/mapr.test.act.gov.au/myexpandedauditlogs/
/opt/mapr/bin/expandaudit -cluster mapr.test.act.gov.au -volumename TCCS -o /mapr/mapr.test.act.gov.au/myexpandedauditlogs/

echo 'Audit logs expanded for the volumes'
echo 'Use Drill explorer to query this data and create views'

