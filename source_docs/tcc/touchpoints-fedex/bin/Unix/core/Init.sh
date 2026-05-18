#!/bin/bash

# ---------------------------------------------------------------
#            CONFIG BOARD
# ---------------------------------------------------------------
# Set the default config board.
DEFAULT_CONFIG_BOARD=$TCC_HOME/system/default.configuration_brd.xml
if  [ ! "$CONFIG_BOARD" ] ;then
	export CONFIG_BOARD=$DEFAULT_CONFIG_BOARD
fi
if  [ ! "$CONFIG_BOARDS_FOLDER" ] ;then
	export CONFIG_BOARD=$DEFAULT_CONFIG_BOARD
fi

# If CONFIG_BOARD is only a filename, prefix it with CONFIG_BOARDS_FOLDER.
if [ "$(basename "$CONFIG_BOARD")" == "$CONFIG_BOARD" ]; then
	export CONFIG_BOARD=$CONFIG_BOARDS_FOLDER/$CONFIG_BOARD
fi

# ---------------------------------------------------------------
#            VALIDATIONS
# ---------------------------------------------------------------
if  [ ! "$TCC_HOME" ] ;then
    echo "### The TCC_HOME variable is mandatory. ###"
    exit 1
fi
if  [ ! -s "$TCC_HOME" ] ;then
    echo "### The TCC_HOME path "$TCC_HOME" does not exist. ###"
    exit 1
fi
if  [ ! "$JAVA_HOME" ] ;then
    echo "### The JAVA_HOME variable is mandatory. ###"
    exit 1
fi
if  [ ! -s "$JAVA_HOME" ] ;then
    echo "### The JAVA_HOME path "$JAVA_HOME" does not exist. ###"
    exit 1
fi
if  [ ! -s "$CONFIG_BOARD" ] ;then
    echo "### The CONFIG_BOARD path "$CONFIG_BOARD" does not exist. ###"
    exit 1
fi

# ---------------------------------------------------------------
#            CREATE FOLDERS
# ---------------------------------------------------------------
if [ ! -d "$TEMP_FOLDER" ] ;then
	mkdir -p "$TEMP_FOLDER"
fi

# ---------------------------------------------------------------
#            FUNCTIONS
# ---------------------------------------------------------------
GetDefaultHost() # -- Get the value of the default host in the configuration board file.
{
	echo $JAVA_HOME/bin/java -jar "$TCC_HOME/lib/saxon8.jar" "$CONFIG_BOARD" ../xsl/GetDefaultHost.xsl
}

GetSymbolValue() # -- Get the value of a symbol in the configuration board file.
								 # symbol[in] - The symbol name.
{
	echo $JAVA_HOME/bin/java -jar "$TCC_HOME/lib/saxon8.jar" "$CONFIG_BOARD" ../xsl/GetSymbolValue.xsl name=$1
}

# ---------------------------------------------------------------
#            READ CONFIGURATION BOARD
# ---------------------------------------------------------------
export TALEO_HOST=$(`GetDefaultHost`)
export ALERTING_MAIL_FROM=$(`GetSymbolValue ALERTING_MAIL_FROM`)
export FTP_HOST=$(`GetSymbolValue FTP_HOST`)
export FTP_PORT=$(`GetSymbolValue FTP_PORT`)
export FTP_USER=$(`GetSymbolValue FTP_USER`)
export FTP_PASSWORD=$(`GetSymbolValue FTP_PASSWORD`)
export FTP_INBOUND_FOLDER=$(`GetSymbolValue FTP_INBOUND_FOLDER`)

# ---------------------------------------------------------------
#            MULTI-ZONE SETTINGS
# ---------------------------------------------------------------
# Indicates if execution reads and writes files in zone-specific folders (true/false). Recommended value is false. 
export MULTI_ZONE=false

if [ "$MULTI_ZONE" == "true" ] ;then
	export LOG_FOLDER=$LOG_FOLDER/$TALEO_HOST
	export LASTRUNDATE_FOLDER=$LASTRUNDATE_FOLDER/$TALEO_HOST
	export MONITOR_FOLDER=$MONITOR_FOLDER/$TALEO_HOST
	export NETCHANGE_REPOSITORY=$%NETCHANGE_REPOSITORY/$TALEO_HOST
	export INBOUND_FOLDER=$INBOUND_FOLDER/$TALEO_HOST
	export OUTBOUND_FOLDER=$OUTBOUND_FOLDER/$TALEO_HOST
	export ARCHIVE_FOLDER=$ARCHIVE_FOLDER/$TALEO_HOST
	export ERROR_FOLDER=$ERROR_FOLDER/$TALEO_HOST
	export TEMP_FOLDER=$TEMP_FOLDER/$TALEO_HOST
fi	

# ---------------------------------------------------------------
#            SET DATE AND TIME VARIABLES
# ---------------------------------------------------------------
export NOW=`date "+%Y%m%d_%H%M%S"`
export TODAY=`date "+%Y%m%d"`

# ---------------------------------------------------------------
#            SET DEFAULT VALUES
# ---------------------------------------------------------------
if [ "$NB_RETRIES" == "" ] ;then
	export NB_RETRIES=0
fi	
