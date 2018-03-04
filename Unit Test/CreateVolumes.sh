#!/bin/bash

#Description: Creates a volume for each listing in directorates.name
#Author: Robert A. Marshall
#Date: 12/10/2017
#Authorized by:
#Last Modified: 17/10/2017
#Audit Log:
#Notes: The script assumes that the script and directorates.name are in the same location. Script does not ignore comments in the directorates.name file.
#--------------------------------------------------------------------------------------------------------------------------------------------------

# Clear the screen
clear

#Variables
DirectoratesFile=/directorates.name #Assumes that .name file is in same location as script file
DirectoratesFilePath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)$DirectoratesFile"

#Body
if [ $USER = mapr ]; then
        while IFS=', ' read -r volName volAE volAEType volAudit volCoalesce volPath volReadAce volWriteAce volPermissions
        do
                echo Creating the $volName volume
                maprcli volume create -createparent 1 -name $volName -ae $volAE -aetype $volAEType -auditenabled $volAudit -coalesce $volCoalesce -path $volPath -readAce $volReadAce -writeAce $volWriteAce -rootdirperms $volPermissions
        mountDir=$(maprcli volume info -name $volName -columns "mountdir") #Checks if volume created
        if [ "$volPath" == ${mountDir#"mountdir"} ]; then #Spits out a generic 'too many arguments' error if the mount directory is not found.
                        echo Succesfully created the $volName volume
                else
                        echo WARNING: The $volName volume was not succesfully created!
        fi
        done < "$DirectoratesFilePath"
        echo Create Volumes Script Completed.
else
        echo ERROR: This script must be run as super user mapr. No volumes created.
fi