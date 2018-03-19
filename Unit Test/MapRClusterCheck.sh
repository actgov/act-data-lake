# ===========================================================================
# Description   : Script to test whether the cluster is working and secure
# Author        : Phil Crawford / Stuart Wilson
# Date          : 14/07/2017
# Last Modified : 08/03/2018
#
# Based on code by Selvaraaju Murugesan
# ===========================================================================
#dog

#Some basic information about the cluster
clear

echo -n "OS : " 
cat /etc/redhat-release
echo "CPU Info : "
echo "--------  " 

# The following command doesn't seem to provide an output in this script
# However running this in the command line does provide the information
val=$( grep '^model name:' /proc/cpuinfo ) 
echo "$val"
echo 
echo -e "Host name :"
hostname -f
echo -e "Host IP :"
hostname -i
echo -e "\n"


# Test 1 : Test whether the cluster is secure or not 

searchstr="secure=true"
file="/opt/mapr/conf/mapr-clusters.conf"
echo "Secure Cluster :"
if grep -q "$searchstr" $file; then
        echo "    Cluster is Secure."
        echo "Test 1: Pass."
else
        echo "    Cluster is not secure."
        echo "Test 1: Fail."
fi
echo -e "\n"

# Test 2 : Number of Nodes
val=$(maprcli dashboard info -json | grep nodesUsed)
echo "Number of Nodes :"
if echo "$val" | grep -q 3 ; then
        echo "    Number of Nodes is 3."
        echo "Test 2: Pass."
else
        echo "    Number of nodes is less than 3."
        echo "Test 2: Fail."
fi
echo -e "\n"

# Test 3 : NFS Mount
val=$(cat /proc/mounts | grep mapr)
#echo $val
echo "NFS Mounted :"
if echo "$val" | grep -q "mapr" && echo "$val" | grep -q "nfs" ; then
        echo "    NFS Mount exists."
        echo "Test 3: Pass."
else
        echo "    No NFS mount."
        echo "Test 3: Fail."
        
fi
echo -e "\n"

# Test 4 : Cluster Audit
# Test Case 78401
echo "Cluster Audit for 365 days :"
val=$( maprcli audit info -json | head -15 | grep retentionDays | cut -d ':' -f2 | tr -d '"')
#echo $val
# Retention dayds is set to 365
if [ "$val" -eq "365" ];then
        echo "    Cluster Audit enabled for 1 year."
        echo "Test 4: Pass."
else
        echo "    No Audit enabled."
        echo "Test 4: Fail."
fi
echo -e "\n"

#Test 5 : Cluster Health
# Test Case

echo "Cluster Alatms raised :"
val=$(maprcli alarm list)
if [[ $val ]]; then
        echo "    Alarms are raised."
	maprcli alarm list
        echo "Test 5: Fail."
else
        echo "    No Alarms raised."
        echo "Test 5: Pass."
fi
echo -e "\n"



 audit info -json | head -15 | grep retentionDays | cut -d ':' -f2 | tr -d '"'c
