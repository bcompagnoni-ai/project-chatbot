#!/bin/bash

### Write the Net-Change configuration (storage.properties) dynamically, using NETCHANGE_REPOSITORY value if defined.

if [ ! "$NETCHANGE_REPOSITORY" = "" ] ;then

	# Set the Net-Change config folder to the TEMP_FOLDER.
	NETCHANGE_CONFIG_FOLDER=$TEMP_FOLDER

	# If empty, use system defined TMPDIR.
	if [ "$NETCHANGE_CONFIG_FOLDER" = "" ] ;then
		NETCHANGE_CONFIG_FOLDER=$TMPDIR
	fi
	
	# Add a random subfolder to avoid conflicts between running instances.
	NETCHANGE_CONFIG_FOLDER=$NETCHANGE_CONFIG_FOLDER/$RANDOM

	# Create NETCHANGE_CONFIG_FOLDER.
	mkdir -p $NETCHANGE_CONFIG_FOLDER
	
	# Create NETCHANGE_REPOSITORY if it does not exist.
	if [ ! -d $NETCHANGE_REPOSITORY ] ;then
		mkdir -p $NETCHANGE_REPOSITORY
	fi
	
	# Prepare an empty storage.properties file.
	STORAGE_PROPERTIES=$NETCHANGE_CONFIG_FOLDER/storage.properties
	if [ -e $STORAGE_PROPERTIES ] ;then
		rm $STORAGE_PROPERTIES 
	fi
	
	# Write storage.properties content.
	echo UseCompression=true>> $STORAGE_PROPERTIES 
	echo EncryptionMode=2>> $STORAGE_PROPERTIES
	echo RepositoryLocation=`cd $NETCHANGE_REPOSITORY; pwd`>> $STORAGE_PROPERTIES
	echo StorageUnitImplementation=com.taleo.integration.storage.FileStorageUnit>> $STORAGE_PROPERTIES
	echo FileStorageUnit.DefaultBlockSize=1>> $STORAGE_PROPERTIES
	
fi