#!/bin/bash

#Description: Deletes the matching volume for each listing in directorates.name
#Author: Robert A. Marshall
#Date: 17/10/2017
#Authorized by:
#Last Modified: 17/10/2017
#Audit Log:
#Notes: Can't force deletion of a parent volume (e.g. '/Data') while it has children.
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
                echo Removing $volName directory
                maprcli volume remove -name $volName -force 1
        done < "$DirectoratesFilePath"

        echo Remove Volumes Script Completed.
else
        echo ERROR: This script must be run as super user mapr. No volumes removed.
fi