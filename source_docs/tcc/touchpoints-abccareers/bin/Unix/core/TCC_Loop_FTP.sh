#!/bin/bash

# $1: Configuration file (e.g. $SCRIPTS_FOLDER/Candidate_merge/Candidate_merge_cfg.xml)
# $2: Input file pattern (e.g. Candidate_*.csv). Will be prepended with $FTP_INBOUND_FOLDER/.
# $3: Output file prefix (e.g. result_). Will be prepended to input file name and placed in the $FTP_OUTBOUND_FOLDER by TCC.

# Create temp folder.
if [ ! -d $TEMP_FOLDER ] ;then
	mkdir "$TEMP_FOLDER"
fi

# Initialize the processing status
fileStatus='success'

# Get List of files from FTP.
FTP_LIST=$TEMP_FOLDER/FTP_List_$RANDOM.tmp
ftp -n -u <<ENDFTP
open $FTP_HOST $FTP_PORT 
user $FTP_USER $FTP_PASSWORD
binary
cd $FTP_INBOUND_FOLDER
prompt
mls $2 $FTP_LIST
bye
ENDFTP

# Initialize the error code.
ERR_CODE=0

# Set the loop index.
export LOOP_INDEX=0

if [ -f $FTP_LIST ] ;then

	# Loop on each file in the FTP inbound folder.
	for i in `cat $FTP_LIST`
	do
		if [ "${ERR_CODE}" == "0" ] ;then
			# Increment the LOOP_INDEX.
			LOOP_INDEX=`expr ${LOOP_INDEX} + 1`

			# Run TCC.
			./core/TCC.sh $1 "$i" "$3$i"
			
			# Store the error code.
			ERR_CODE=$?
		else
			exit ${ERR_CODE}
		fi	
	done
	
	# Delete the temporary file list.
	rm $FTP_LIST
	
else
	echo "No file matching $FTP_INBOUND_FOLDER/$2"
fi


