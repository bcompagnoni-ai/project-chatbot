#!/bin/bash

### $1: Mode
###				copy: Take a copy of the file and append a timestamp to its name.
###				move: Simply move the file.
###				copy_no_timestamp: Take a copy of the file without appending a timestamp to its name.
### $2: File to archive
### $3: Error code

# Set the ERR_CODE.
ERR_CODE=$3
if [ "${ERR_CODE}" == "" ]; then
	echo "### The error code (third parameter) is mandatory. ###"
	exit 1
fi

# Create archive and error folders.
if [ ! -d ${ARCHIVE_FOLDER} ] ;then
	mkdir "${ARCHIVE_FOLDER}"
fi
if [ ! -d ${ERROR_FOLDER} ] ;then
	mkdir "${ERROR_FOLDER}"
fi

# Extract filename and extension.
filename=`basename "$2"`
extension=${filename##*.}
filename=${filename%.*}

# Copy or move sucessfully processed file to archive folder and failures to error folder.
if [ "${ERR_CODE}" == "0" ]; then
 DEST_FOLDER=${ARCHIVE_FOLDER}
else
 DEST_FOLDER=${ERROR_FOLDER}
fi
if [ "$1" = "copy" ] ;then
	cp "$2" "${DEST_FOLDER}/${filename}_${NOW}.${extension}"
fi
if [ "$1" = "move" ] ;then
	mv "$2" "${DEST_FOLDER}/${filename}.${extension}"
fi
if [ "$1" = "copy_no_timestamp" ] ;then
	cp "$2" "${DEST_FOLDER}/${filename}.${extension}"
fi

# Exit with the same error code.
exit ${ERR_CODE}