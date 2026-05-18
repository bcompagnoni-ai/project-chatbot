#!/bin/bash

# $1: Configuration file (e.g. $SCRIPTS_FOLDER/Candidate_merge/Candidate_merge_cfg.xml)
# $2: Input file folder & pattern (e.g. $INBOUND_FOLDER/Candidate_*.csv).
# $3: Output file folder & prefix (e.g. $OUTBOUND_FOLDER/result_).

# Initialize the error code.
ERR_CODE=0

# Set the loop index.
export LOOP_INDEX=0

# Loop on each file matching the pattern, exit if one of the file fails.
for i in $(find "`dirname "$2"`" -type f -name "`basename "$2"`" -print)
do
	if [ "${ERR_CODE}" == "0" ] ;then
		# Increment the LOOP_INDEX.
		LOOP_INDEX=`expr ${LOOP_INDEX} + 1`

		# Run TCC.
		./core/TCC.sh "$1" "$i" "$3`basename "$i"`"
		
		# Store the error code.
		ERR_CODE=$?
		
		# Archive and exit if there is an error.
		./core/Archive.sh move "$i" ${ERR_CODE}
	else
		exit ${ERR_CODE}
	fi
done