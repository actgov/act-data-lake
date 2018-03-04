# ===============================================================================================================================
# Descriptiopn :  Script to test whtther the cluster is secuered or not
# Author       : Selvaraaju Murugesan
# Date         : 14/07/2017
# Authorsed by :
# Last Modified: 16/10/2017
# Audi Log     : Added new code to validate some operations
# ===============================================================================================================================


#Some basic information about the cluster
clear

echo "OS :" 
cat /etc/*release | grep -m1 -i -o -e ubuntu -e redhat -e 'red hat' -e centos
echo -e "\n CPU Info"
grep '^model name' /proc/cpuinfo | sort -u
echo -e "\n Host name"
hostname -f
echo -e "\n Host IP"
hostname -i
echo -e "\n"


# Test 1 : Test whether the cluster is secure or not 

searchstr="secure=rue"
file="/opt/mapr/conf/mapr-clusters.conf"
if grep -q "$searchstr" $file;
        echo "Cluster is Secure"
        echo "Test 1 Pass"
else
        echo "Test 1 Fail : Cluster is not Secure"
fi
echo -e "\n"

# Test 2 : Number of Nodes
val=$(maprcli dashboard info -json | grep nodesUsed)
echo "Number of Nodes"
if echo "$val" | grep -q 3 ; then
        echo "Number of Nodes is 3"
        echo "Test 2 Pass "
else
        echo "Test 2 Fail : Number of nodes is less than 3"
fi
echo -e "\n"

# Test 3 : NFS Mount
val=$(cat /proc/mounts | grep mapr)
#echo $val
echo "NFS Mounted ?"
if echo "$val" | grep -q "mapr" && echo "$val" | grep -q "nfs" ; then
        echo "NFS Mount True"
        echo "Test 3 Pass "
else
        echo "Test 3 Fail : No NFS mount"
fi
echo -e "\n"

# Test 4 : Cluster Audit
# Test Case 78401
echo "Cluster Audit Enabled ?"
val=$( maprcli audit info -json | head -15 | grep retentionDays | cut -d ':' -f2 | tr -d '"')
#echo $val
# Retention dayds is set to 365
if [ "$val" -eq "365" ];then
        echo "Cluster Audit Enabled"
        echo "Test 4 Pass "
else
        echo "Test 4 Fail : No Audit Enabled"
fi
echo -e "\n"

#Test 5 : Cluster Health
# Test Case

echo "Cluster Alatms raised ?"
val=$(maprcli alarm list)
if [[ $val ]]; then
        echo "Alarms are raised"
        echo "Test 5 Fail"
else
        echo "No Alarms raised"
        echo "Test 5 Pass"
fi

#Test 6 : Linux version
# Test Case

