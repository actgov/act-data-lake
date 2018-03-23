# =================================================================================
# Description   : Script to test MapR alerts are working for excess data in Volumes
# Author        : Stuart Wilson
# Date          : 21/03/2018
# Last Modified : 22/03/2018
#
# ================================================================================

# Varibles for this script
TempDir=$"/tmp"

# Below is a variable (random word) that is used to ensure these are unique tests
NameVar=$"Blue"
echo
echo "(" $NameVar "is the unique word to ensure these tests are current.)"
echo

# Create blanket data files using Cyclist_Crashes.csv as a seed
#  This should create test0.data (~100MB) and test1.data (~161MB)
echo "Creating test.data files..."
echo
cat Cyclist_Crashes.csv > test0.data
cat test0.data > test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
cat test1.data >> test0.data
cat test0.data >> test1.data
mv ./test1.data $TempDir/test1${NameVar}.data
mv ./test0.data $TempDir/test0${NameVar}.data


# Show files
echo "Here are the files created"
val=$"$TempDir/test*"
echo $val
ls -hl $val
echo
 
# Creating a volume called
echo "Now we create a volume called Volume$NameVar"
echo
maprcli volume create -name "Volume"$NameVar -path /Volume$NameVar -advisoryquota 100M -quota 500M -replication 3 -schedule 2 -type rw
read -p "Pause until the volume is up and the data is replicated"
echo

echo "CLI check - search for Volume"$NameVar
maprcli volume list -json | grep "Volume$NameVar"
echo 


<<<<<<< HEAD
echo    "Just created a volume called Volume"$NameVar", please confirm in the MCS"
echo
read -p "Or press Enter"
echo 
# Check and change the quota for the volume

echo "Now we will change quota and advisory quota for Volume"$NameVar
echo
echo "Currently the quotas are"
maprcli volume info -name "Volume$NameVar" -json | grep quota
echo
echo "Now we're changing the quotas..."
maprcli volume modify -name "Volume$NameVar" -advisoryquota 500MB
maprcli volume modify -name "Volume$NameVar" -quota 600MB
echo
echo "Let's see what the quota are now"
maprcli volume info -name "Volume$NameVar" -json | grep quota
echo
=======
hi there
>>>>>>> 85fd295eb1d8f0b6a2029194be39487b08fe4698

# Now we fill up the disks and set off the alarms


echo "Now we will fill up the volume with our test data and trigger the alarms"
echo
# variables for source and destination
val1=$"$TempDir/test*"
val2=$"/Volume$NameVar"

echo "We first make a directory on our volume"
val3=$"$val2/Sub$NameVar"

echo $val3
hadoop fs -mkdir $val3
echo
read -p "Pause to look"
echo
echo "We now copy $val1 to $val2"

echo "hadoop fs -copyFromLocal $val1 $val3/"

hadoop fs -copyFromLocal $val1 $val3/

echo "hadoop fs -copyFromLocal $val1 $val3/test2.data"

hadoop fs -copyFromLocal $val1 $val3/test2.data 

echo
echo "Let's print out what has been copied"

hadoop fs -ls $val3

read -p "Pause"



# Remove the volume
echo
echo "Now we remove the volume"
echo
read -p "Are you sure you want to remove the volume?"
maprcli volume remove -force true -name Volume$NameVar
echo "Here are the volumes left"
maprcli volume list -json | grep volumename

# Remove data files 

rm $TempDir/test1${NameVar}.data
rm $TempDir/test0${NameVar}.data











