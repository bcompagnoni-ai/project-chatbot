#!/bin/bash

# ---------------------------------------------------------------
#            TCC HOME
# ---------------------------------------------------------------
export TCC_HOME=/u01/Taleo/tcc-17.0.0.0.10/

# ---------------------------------------------------------------
#            CONFIGURATION BOARD
# ---------------------------------------------------------------
# Note: File name of the configuration board in the /configboards folder. Leave blank to use TCC default.
export CONFIG_BOARD=zone_brd.xml

# ---------------------------------------------------------------
#            JAVA SETTINGS
# ---------------------------------------------------------------
export JAVA_HOME=/usr
# Note: Java maximum available memory (typically 256m, 512m, 1024m or 2048m)
export JAVA_XMX=512m

# ---------------------------------------------------------------
#            FOLDER SETTINGS
# ---------------------------------------------------------------
# Note: Folders can be set as relative or absolute, including mapped drives and UNC paths.
export INBOUND_FOLDER=../../data/inbound
export OUTBOUND_FOLDER=../../data/outbound
export ARCHIVE_FOLDER=../../data/archive
export ERROR_FOLDER=../../data/error
export CONFIG_BOARDS_FOLDER=../../configboards
export CUSTOM_DICTIONARIES_FOLDER=../../customdictionaries
#export FEATUREPACKS_FOLDER=../../featurepacks
export FEATUREPACKS_FOLDER=/u01/Taleo/TCCApplicationDataModel-17.0.0.6
export LOG_FOLDER=../../log
export LIB_FOLDER=../../lib
export LASTRUNDATE_FOLDER=../../lrd
export MONITOR_FOLDER=../../monitor
export NETCHANGE_FOLDER=../../net-change
export NETCHANGE_REPOSITORY=$NETCHANGE_FOLDER/repository
export SCRIPTS_FOLDER=../../scripts
export TEMP_FOLDER=../../temp

# ---------------------------------------------------------------
#            PROXY SETTINGS
# ---------------------------------------------------------------
export PROXY_HOST=
export PROXY_PORT=
export PROXY_USER=
# Note: Password can be encrypted using \bin\Windows\EncryptPassword.bat
export PROXY_PASSWORD=
export PROXY_NTDOMAIN=

# ---------------------------------------------------------------
#            RUN SETTINGS
# ---------------------------------------------------------------
export NB_RETRIES=2

# ---------------------------------------------------------------
#            CLEANUP SETTINGS
# ---------------------------------------------------------------
# Note: Number of days old files will be kept in the log, monitor, outbound, archive and error folders, when using the Cleanup.bat script.
export RETENTION_DAYS=31

# ---------------------------------------------------------------
#            INITIALIZE
# ---------------------------------------------------------------
. ./core/Init.sh