# =================================================================================
# Description   : Script to test MapR alerts are working for excess data in Volumes
# Author        : Stuart Wilson
# Date          : 21/03/2018
# Last Modified : 21/03/2018
#
# ================================================================================

# Varibles for this script
TempDir=$"/tmp/"

# Below is a variable (random word) that is used to ensure these are unique tests
NameVar=$"Giraffe"
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
mv ./test1.data ./test1${NameVar}.data
mv ./test0.data ./test0${NameVar}.data


# Show files
ls -hl test*.data 
echo 


# Continue to copy files to cluster and check alerts until visually confirmed

echo "Please open up MCS"
echo
<<<<<<< HEAD
# 
=======


# Change quota and advisory quota for $VolumeNameVar volume

echo "Changing quota and advisory quota for Volume" $VolumeNameVar

if [maprcli volume info -name Volume$NameVar -json |grep -q "Volume"$NameVar]; then
    echo "yes" 
else
    echo "no"
fi

read -p "pause"


maprcli volume create -name "Volume"$NameVar -path /Data/$NameVar -advisoryquota 100M -quota 500M -replication 3 -schedule 2 -type rw

maprcli volume info -name $VolumeNameVar -json |grep "quota"


read -p ""

""

maprcli volume modify -name Directorate1 -advisoryquota 500MB
maprcli volume modify -name Directorate1 -quota 750MB












>>>>>>> e9f3b0d... remove large files


