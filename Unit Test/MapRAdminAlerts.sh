# =================================================================================
# Description   : Script to test MapR alerts are working for excess data in Volumes
# Author        : Stuart Wilson
# Date          : 21/03/2018
# Last Modified : 01/06/2018
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
NameVar=$"Orange"
echo
echo "(" $NameVar "is the unique word to ensure these tests are current.)"
echo


# Create blanket data files using Cyclist_Crashes.csv as a seed
#  This should create test0.data (~100MB) and test1.data (~161MB)
echo "Creating testdata files."
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
echo "${cc_green}  maprcli volume create -name "Volume"$NameVar -path /Volume$NameVar -advisoryquota 100M -quota 500M -replication 3 -schedule 2 -type rw"
maprcli volume create -name "Volume"$NameVar -path /Volume$NameVar -advisoryquota 100M -quota 500M -replication 3 -schedule 2 -type rw
echo "${cc_normal}"
#read -p "(Pause)"
echo
sleep 6 

# Confirm that the volume name has been created
echo
echo "Let's confirm the $VolumeName volume has been created"
echo
echo "${cc_green}  maprcli volume list -json | grep $VolumeName ${cc_normal}"
echo
maprcli volume list -json | grep $VolumeName
echo
echo "Just created a volume called "$VolumeName", which can also be confirmed in the MCS"
echo
#read -p "(Pause)"
echo 


# Check and change the quota for the volume
echo
echo "Now we will change quota and advisory quota for $VolumeName."
echo
echo "Currently the quotas are."
echo
echo "${cc_green}  maprcli volume info -name $VolumeName -json | grep quota ${cc_normal}"
echo
maprcli volume info -name $VolumeName -json | grep quota
echo
echo "Now we're changing the quotas..."
maprcli volume modify -name $VolumeName -advisoryquota 500MB
maprcli volume modify -name $VolumeName -quota 600MB
echo
echo "Let's see what the quota are now."
maprcli volume info -name $VolumeName -json | grep quota
echo
#read -p "(Pause)"
echo


# Now we fill up the disks and set off the alarms
echo
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
#read -p "(Pause)"
echo

# Copy files over to the directory
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
#read -p "(Pause)"
echo


################################################################################
#  Create a snapshot
SnapShot="SnapShot"$NameVar
echo
echo "Now we will create a snapshot of the Volume "$VolumeName" called "$SnapShot
echo
echo "${cc_green}  maprcli volume snapshot create -snapshotname $SnapShot -volume $VolumeName ${cc_normal}"
echo
maprcli volume snapshot create -snapshotname $SnapShot -volume $VolumeName
echo
echo
echo "Let's confirm the snapshot was created"
echo 
echo "${cc_green}  maprcli volume snapshot list -volume "$VolumeName" ${cc_normal}"
echo
maprcli volume snapshot list -volume $VolumeName
echo
#read -p "(Pause)"
echo
echo "Let's delete the file "$VolumeDirDL"/test1.data"
echo "The files present are ..."
hadoop fs -ls $VolumeDirDL/
echo 
echo "Now let's delete it"
echo
echo "${cc_green}  hadoop fs -rm "$VolumeDirDL"/test1$NameVar.data${cc_normal}" 
echo
hadoop fs -rm $VolumeDirDL/test1$NameVar.data
echo
echo "Confirm it's gone"
echo
hadoop fs -ls $VolumeDirDL/
echo
#read -p "(Pause)"
echo
echo "Now let's recover the file from the snapshot."
echo
echo "${cc_green}  hadoop fs -cp /$VolumeName/.snapshot/$SnapShot/$DirectoryDL/test1$NameVar.data $VolumeDirDL/test1$NameVar.data_recovered${cc_normal}"
echo
hadoop fs -cp /$VolumeName/.snapshot/$SnapShot/$DirectoryDL/test1$NameVar.data $VolumeDirDL/test1$NameVar.data_recovered
echo
echo "Now let's check that it's there"
echo
hadoop fs -ls $VolumeDirDL
echo
#read -p "(Pause)"
echo




# Make copies of the same file on the cluster
echo
echo "Now let's make multiple copies of these files on the cluster to fill up the quota."
echo
echo "${cc_green}  hadoop fs -cp $VolumeDirDL/test1* $VolumeDirDL/test2.data"
hadoop fs -cp $VolumeDirDL/test1* $VolumeDirDL/test2.data
echo "  hadoop fs -cp $VolumeDirDL/test2* $VolumeDirDL/test3.data"
hadoop fs -cp $VolumeDirDL/test2* $VolumeDirDL/test3.data
#echo "  hadoop fs -cp $VolumeDirDL/test3* $VolumeDirDL/test4.data"
#hadoop fs -cp $VolumeDirDL/test3* $VolumeDirDL/test4.data
#echo "  hadoop fs -cp $VolumeDirDL/test4* $VolumeDirDL/test5.data"
#hadoop fs -cp $VolumeDirDL/test4* $VolumeDirDL/test5.data
#echo "  hadoop fs -cp $VolumeDirDL/test5* $VolumeDirDL/test6.data$"
#hadoop fs -cp $VolumeDirDL/test5* $VolumeDirDL/test6.data
echo "${cc_normal}"
echo "Let's see what's been replicated." 
echo
echo "${cc_green}  hadoop fs -ls $VolumeDirDL/${cc_normal}"
echo
hadoop fs -ls $VolumeDirDL/
echo
#read -p "(Pause)"
echo

# Change some of the permissions for the current setup
echo
echo "Let's have a look at the ACL permissions"
echo
#  maprcli volume info -name VolumeBlue | grep -P -o '(?<=acl).*?(?=})'
echo "${cc_green}  maprcli acl show -type volume -name $VolumeName ${cc_normal}"
echo 
maprcli acl show -type volume -name $VolumeName
echo
echo "Now lets add a user with some permissions"
echo 
echo "${cc_green}  maprcli acl edit -type volume -name $VolumeName -user stuart_wilson:dump,a ${cc_normal}"
echo
maprcli acl edit -type volume -name $VolumeName -user stuart_wilson:dump,a
echo
echo "And let's look at the user list again."
echo
echo "${cc_green}  maprcli acl show -type volume -name $VolumeName ${cc_normal}"
echo 
maprcli acl show -type volume -name $VolumeName 
echo
#read -p "(Pause)"
echo

# make a file write only 

echo
echo "Let's look at the ACE for the first file."
echo
echo "${cc_green}  hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo  
hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data
echo
echo "Now let's stop user stuart_wilson from reading this file."
echo 
echo "${cc_green}  hadoop mfs -setace -readfile '!u:stuart_wilson' $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
hadoop mfs -setace -readfile '!u:stuart_wilson' $VolumeDirDL/test0"$NameVar".data

echo "Now let's check that he has been blocked"
echo 
echo "${cc_green}  hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data
echo
echo "To check run hadoop fs -tail $VolumeDirDL/test0"$NameVar".data (for test0 and test1) for both a mapr user and for stuart_wilson."
echo
#read -p "(Pause)"
echo


# Set read permissions for a file to a specific AD group

echo
echo "Now let us set the read permissions for a file to a specifice AD group"
echo
echo "Looking at the ACE for the first file:"
echo
echo "${cc_green}  hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
echo "(N.B. - this is a dangerous command as it removes previous permissions when new permissions are added. This can be seen in the following example.)"
echo
hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data
echo
echo "Now let's set the read permissions for this file to the AD group 'ebis-bs_tst_rdpuser_-_ebis_warehouse'."
echo
echo "${cc_green}  hadoop mfs -setace -readfile 'g:ebis-bs_tst_rdpuser_-_ebis_warehouse' $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
hadoop mfs -setace -readfile 'g:ebis-bs_tst_rdpuser_-_ebis_warehouse' $VolumeDirDL/test0"$NameVar".data
echo
echo "Now let's check that the read permissions have been changed."
echo
echo "${cc_green}  hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data
echo
echo "To check run 'hadoop fs -tail $VolumeDirDL/test0"$NameVar".data' to try and read the tail end of the test0 file, both for a member of the 'ebis-bs_tst_rdpuser_-_ebis_warehouse' group (namely P.C) and also check for a non-member (possibly S.W.)."
echo
#read -p "(Pause)"
echo

# Set write permissions for a file to a specific AD group
echo
echo "Now let us set the write permissions for a file to a specifice AD group"
echo
echo "Looking at the ACE for the first file:"
echo
echo "${cc_green}  hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
echo "(N.B. - this is a dangerous command as it removes previous permissions when new permissions are added. This can be seen in the following example.)"
echo
hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data
echo
echo "Now let's set the write permissions for this file to the AD group 'ebis-bs_tst_rdpuser_-_ebis_warehouse'."
echo
echo "${cc_green}  hadoop mfs -setace -writefile 'g:ebis-bs_tst_rdpuser_-_ebis_warehouse' $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
hadoop mfs -setace -writefile 'g:ebis-bs_tst_rdpuser_-_ebis_warehouse' $VolumeDirDL/test0"$NameVar".data
echo
echo "Now let's check that the write permissions have been changed."
echo
echo "${cc_green}  hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data${cc_normal}"
echo
hadoop mfs -getace $VolumeDirDL/test0"$NameVar".data
echo
echo "To check run 'echo "some test words" | hadoop fs -appendToFile - $VolumeDirDL/test0"$NameVar".data' by a user from the group 'ebis-bs_tst_rpduser...' to append some random 'test words' to the file, then run 'hadoop fs -tail $VolumeDirDl/test0"$NameVar".data' to confirm the file has been written to."
echo
#read -p "(Pause)"
echo

# Fill up the drive
#echo
#echo "Now let's continue filling up the volume with copies of the data files"
#echo
#echo "${cc_green}  hadoop fs -cp $VolumeDirDL/test6* $VolumeDirDL/test7.data"
#hadoop fs -cp $VolumeDirDL/test6* $VolumeDirDL/test7.data
#echo "  hadoop fs -cp $VolumeDirDL/test7* $VolumeDirDL/test8.data"
#hadoop fs -cp $VolumeDirDL/test7* $VolumeDirDL/test8.data
#echo "  hadoop fs -cp $VolumeDirDL/test8* $VolumeDirDL/test9.data"
#hadoop fs -cp $VolumeDirDL/test8* $VolumeDirDL/test9.data
#echo "  hadoop fs -cp $VolumeDirDL/test9* $VolumeDirDL/test10.data$"
#hadoop fs -cp $VolumeDirDL/test9* $VolumeDirDL/test10.data
echo
echo "${cc_normal}Let's see what else has been replicated." 
echo
echo "${cc_green}  hadoop fs -ls $VolumeDirDL/${cc_normal}"
echo 
hadoop fs -ls $VolumeDirDL/
echo
#read -p "(Pause)"
# Remove the volume
echo
echo "Now we remove the volume."
echo
#read -p "(Are you sure you want to remove the volume?)"
echo
#read -p "(Sure?)"
maprcli volume remove -force true -name Volume$NameVar
echo "Here are the volumes left"
maprcli volume list -json | grep volumename

# Remove data files 

rm $LocalDir/test1${NameVar}.data
rm $LocalDir/test0${NameVar}.data












