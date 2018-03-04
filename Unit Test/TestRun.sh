!/bin/sh
#----------------------------------------------------------------------------------
# Description       : Program to test funcationality of HIVE
# Author            : Selvaraaju Murugesan
# Date Created      : 01-Aug-2017
# Modified Log      : 
# Las Modified Date : 
#----------------------------------------------------------------------------------
# clear the screen
clear

# Test Case 1 : Hive Internal Database Creation
echo 'Test Case 1 : Creation of HIVE Internal database and Tables'
FILE=/home/TestScripts/Choose.properties
dbname=$(grep -i 'DatabaseName' $FILE  | cut -f2 -d'=')
tablename=$(grep -i 'TableName' $FILE  | cut -f2 -d'=')
echo "Creating an internal database - " $dbname
echo  "and an internal Hive table - " $tablename
hive -hiveconf DB_NAME=$dbname -hiveconf TABLE_NAME=$tablename -f /TestScripts/Query.hql
clear
echo 'CrashDB was created; Crash is the table name; View has been created; Go to Hue to perform querying operations in Hive'
read -rsp $'Press any key to continue...to drop table, view and database\n' -n1 key
hive -hiveconf DB_NAME=$dbname -hiveconf TABLE_NAME=$tablename -f /TestScripts/QueryPurge.hql
# Need validation Code here : Future development
echo 'Database has been purged'
echo 'Test Pass'

#----------------------------------------------------------------------------------

read -rsp $'Press any key to continue to next test case ...' -n1 key

#----------------------------------------------------------------------------------

# Test Case 2 : Hive External Database Creation

echo 'Test Case 2 : Creation of HIVE External database and Tables'
FILE=/home/TestScripts/Choose.properties
extdbname=$(grep -i 'ExtDatabaseName' $FILE  | cut -f2 -d'=')
exttablename=$(grep -i 'ExtTableName' $FILE  | cut -f2 -d'=')
echo "Creating an external database - " $extdbname
echo  "and an external Hive table - " $exttablename
hive -hiveconf DB_NAME=$extdbname -hiveconf TABLE_NAME=$exttablename -f /home/TestScripts/Query_External.hql
#clear
echo -e '\n External database and table creation successful; Hive view is created ; \n Perform Querying operations in Hive'
read -rsp $'Press any key to continue...to drop \ partition n' -n1 key
hive -hiveconf DB_NAME=$extdbname -hiveconf TABLE_NAME=$exttablename -f /TestScripts/QueryExtPurge.hql
echo 'One parition is dropped'
# Need validation Code here : Future development
echo 'Test Pass'
#----------------------------------------------------------------------------------
# Test Case 3 : Create HIVE view to point to current parittion

echo 'Test Case 3 : Creation of HIVE View that points to current partition'
FILE=/home/TestScripts/Choose.properties
hdbname=$(grep -i 'HDatabaseName' $FILE  | cut -f2 -d'=')
htablename=$(grep -i 'HTableName' $FILE  | cut -f2 -d'=')
hviewname=$(grep -i 'HViewName' $FILE  | cut -f2 -d'=')
echo "Creating an nternal  database - " $hdbname
echo  "and an internal Hive table - " $htablename
hive -hiveconf DB_NAME=$hdbname -hiveconf TABLE_NAME=$htablename hiveconf VIEW_NAME=$hviewname -f /TestScripts/Query_View.hql

# Need validation Code here : Future development
echo 'Test Pass'

