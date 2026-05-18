#!/bin/bash

# Delete files that are older than a given number of days.

# Ensure the current directory is set.
cd `dirname "$0"`

# Set the environment variables.
. ./Environment.sh

# Do the cleanup.
find "$LOG_FOLDER" -name "*.*" -type f -ctime +$RETENTION_DAYS -exec rm {} \;
find "$MONITOR_FOLDER" -name "*.*" -type f -ctime +$RETENTION_DAYS -exec rm {} \;
find "$OUTBOUND_FOLDER" -name "*.*" -type f -ctime +$RETENTION_DAYS -exec rm {} \;
find "$ARCHIVE_FOLDER" -name "*.*" -type f -ctime +$RETENTION_DAYS -exec rm {} \;
find "$ERROR_FOLDER" -name "*.*" -type f -ctime +$RETENTION_DAYS -exec rm {} \;

# TEMP_FOLDER is set to keep files only 1 day and delete subfolders.
find "$TEMP_FOLDER" -name "*.*" -type f -ctime +1 -exec rm {} \;
find "$TEMP_FOLDER" -name "*" -type d -ctime +1 -exec rm -r {} \;

