# =================================================================================
# Description   : Script to test MapR alerts are working for excess data in Volumes
# Author        : Stuart Wilson
# Date          : 21/03/2018
# Last Modified : 22/03/2018
#
# ================================================================================

# Escape code
esc=`echo -en "\033"`

# Set colors
cc_red="${esc}[0;31m"
cc_green="${esc}[0;32m"
cc_yellow="${esc}[0;33m"
cc_blue="${esc}[0;34m"
cc_normal=`echo -en "${esc}[m\017"`

# Varibles for this script
LocalDir=$"/tmp"

# Below is a variable (random word) that is used to ensure these are unique tests
NameVar=$"Blue"
echo
echo "(" $NameVar "is the unique word to ensure these tests are current.)"
echo


# Create blanket data files using Cyclist_Crashes.csv as a seed
#  This should create test0.data (~100MB) and test1.data (~161MB)
echo "Creating testdata files."
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
mv ./test1.data $LocalDir/test1${NameVar}.data
mv ./test0.data $LocalDir/test0${NameVar}.data


# Show files
echo
echo "Here are the files created."
echo
ls -hl $LocalDir/test*
echo

 
# Creating a volume called
VolumeName="Volume"$NameVar
echo
echo "Now we create a volume called $VolumeName."
echo
maprcli volume create -name "Volume"$NameVar -path /Volume$NameVar -advisoryquota 100M -quota 500M -replication 3 -schedule 2 -type rw
echo
read -p "(Pause)"
echo

echo "Let's confirm the $VolumeName volume has been created"
echo
maprcli volume list -json | grep $VolumeName
echo
echo "Just created a volume called "$VolumeName", which can also be confirmed in the MCS"
echo
read -p "(Pause)"
echo 

# Check and change the quota for the volume

echo "Now we will change quota and advisory quota for $VolumeName."
echo
echo "Currently the quotas are."
maprcli volume info -name $VolumeName -json | grep quota
echo
echo "Now we're changing the quotas..."
maprcli volume modify -name $VolumeName -advisoryquota 500MB
maprcli volume modify -name $VolumeName -quota 600MB
echo
echo "Let's see what the quota are now."
maprcli volume info -name $VolumeName -json | grep quota
echo


# Now we fill up the disks and set off the alarms


echo "Now we will fill up the volume with our test data and trigger the alarms."
echo
# variables for source and destination
DirectoryDL=$"Dir$NameVar"
VolumeDirDL=$"/$VolumeName/$DirectoryDL"
echo
echo "We first make a directory called $DirectoryDL on our volume $VolumeName."
echo
echo "${cc_green}  hadoop fs -mkdir $VolumeDirDL${cc_normal}"
hadoop fs -mkdir $VolumeDirDL 
echo
echo "Let's confirm the directory was created."
echo
echo "${cc_green}  hapdoop fs -ls /$VolumeName ${cc_normal}"
echo
hadoop fs -ls /$VolumeName
echo
read -p "(Pause)"

echo
echo "Now we will copy files over to the directory on the volume."
echo
echo "Let's copy "$LocalDir"/test* to "$VolumeDirDL
echo
echo "${cc_green}  hadoop fs -copyFromLocal $LocalDir/test* $VolumeDirDL/${cc_normal}"
echo
hadoop fs -copyFromLocal $LocalDir/test* $VolumeDirDL/
#hadoop fs -cp /VolumeBlue/SubBlue/test1Blue.data /VolumeBlue/SubBlue/test3Blue.data
echo
echo "Let's confirm what has been copied."
echo
echo "${cc_green}  hadoop fs -ls $VolumeDirDL${cc_normal}"
echo
hadoop fs -ls $VolumeDirDL 
echo
read -p "(Pause)"


echo
echo "Now let's make copies of these files a few times to fill up the quota."
echo
echo "${cc_green}  hadoop fs -cp $VolumeDirDL/test1* $VolumeDirDL/test2.data"
hadoop fs -cp $VolumeDirDL/test1* $VolumeDirDL/test2.data
echo "  hadoop fs -cp $VolumeDirDL/test2* $VolumeDirDL/test3.data"
hadoop fs -cp $VolumeDirDL/test2* $VolumeDirDL/test3.data
echo "  hadoop fs -cp $VolumeDirDL/test3* $VolumeDirDL/test4.data"
hadoop fs -cp $VolumeDirDL/test3* $VolumeDirDL/test4.data
echo "  hadoop fs -cp $VolumeDirDL/test4* $VolumeDirDL/test5.data"
hadoop fs -cp $VolumeDirDL/test4* $VolumeDirDL/test5.data
echo "  hadoop fs -cp $VolumeDirDL/test5* $VolumeDirDL/test6.data${cc_normal}"
hadoop fs -cp $VolumeDirDL/test5* $VolumeDirDL/test6.data
echo
echo "Let's see what's been replicated." 
echo
echo "${cc_green}  hadoop fs -ls $VolumeDirDL/${cc_normal}"
echo
hadoop fs -ls $VolumeDirDL/
echo
read -p "(Pause)"

echo "${cc_green}  hadoop fs -cp $VolumeDirDL/test6* $VolumeDirDL/test7.data"
hadoop fs -cp $VolumeDirDL/test6* $VolumeDirDL/test7.data
echo "  hadoop fs -cp $VolumeDirDL/test7* $VolumeDirDL/test8.data"
hadoop fs -cp $VolumeDirDL/test7* $VolumeDirDL/test8.data
echo "  hadoop fs -cp $VolumeDirDL/test8* $VolumeDirDL/test9.data"
hadoop fs -cp $VolumeDirDL/test8* $VolumeDirDL/test9.data
echo "  hadoop fs -cp $VolumeDirDL/test9* $VolumeDirDL/test10.data${cc_normal}"
hadoop fs -cp $VolumeDirDL/test9* $VolumeDirDL/test10.data
echo
echo "Let's see what else has been replicated." 
echo
echo "${cc_green}  hadoop fs -ls $VolumeDirDL/${cc_normal}"
echo 
hadoop fs -ls $VolumeDirDL/
echo
read -p "(Pause)"
# Remove the volume
echo
echo "Now we remove the volume."
echo
read -p "(Are you sure you want to remove the volume?)"
echo
read -p "(Sure?)"
maprcli volume remove -force true -name Volume$NameVar
echo "Here are the volumes left"
maprcli volume list -json | grep volumename

# Remove data files 

rm $LocalDir/test1${NameVar}.data
rm $LocalDir/test0${NameVar}.data












