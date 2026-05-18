#!/bin/bash

# Arguments:
# $1: TCC configuration file
# $2: Optional - TCC query file
# $3: Optional - Result file

# ---------------------------------------------------------------
#           VALIDATIONS
# ---------------------------------------------------------------
if  [ ! "$TALEO_HOST" ] ;then
    echo "### The TALEO_HOST variable is mandatory. ###"
    exit 1
fi

echo "Executing at the following endpoint: $TALEO_HOST"

# Build the Java classpath.
CLASSPATH=core
CLASSPATH=$CLASSPATH:$TCC_HOME/lib/taleo-integrationclient.jar
if [ -d "$LIB_FOLDER" ] ;then
	if [ "$(ls -A "$LIB_FOLDER")" ] ;then
		for i in $LIB_FOLDER/*.jar 
		do
		CLASSPATH=$CLASSPATH:$i
		done
	fi
fi

# Build the Java options.
JAVA_OPTS="-Xms512m -Xmx$JAVA_XMX"

# TCC configuration.
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.install.dir=\"$TCC_HOME\""
JAVA_OPTS="$JAVA_OPTS -Djava.endorsed.dirs=\"$TCC_HOME/lib/endorsed\""
JAVA_OPTS="$JAVA_OPTS -Djavax.xml.xpath.XPathFactory:http://java.sun.com/jaxp/xpath/dom=net.sf.saxon.xpath.XPathFactoryImpl"
JAVA_OPTS="$JAVA_OPTS -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl"
JAVA_OPTS="$JAVA_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"
JAVA_OPTS="$JAVA_OPTS -Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.Log4JLogger"
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.LOG_FOLDER=\"$LOG_FOLDER\""
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.configuration.board.default.file=\"`cd $(dirname "$CONFIG_BOARD"); pwd`/$(basename "$CONFIG_BOARD")\""
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.NOW=\"$NOW\""
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.TODAY=\"$TODAY\""
if [ "$LOOP_INDEX" = "" ] ;then 
	LOOP_INDEX=0
fi
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.LOOP_INDEX=\"$LOOP_INDEX\""
if [ ! "$LASTRUNDATE_FOLDER" = "" ] ;then
	mkdir -p "$LASTRUNDATE_FOLDER"
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.lastrundates.dir=\"`cd $LASTRUNDATE_FOLDER; pwd`\""
fi
if [ ! "$CUSTOM_DICTIONARIES_FOLDER" = "" ] ;then
	mkdir -p "$CUSTOM_DICTIONARIES_FOLDER"
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.customdictionaries.dir=\"`cd $CUSTOM_DICTIONARIES_FOLDER; pwd`\""
fi
if [ ! "$MONITOR_FOLDER" = "" ] ;then
	mkdir -p "$MONITOR_FOLDER"
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.MONITOR_FOLDER=\"`cd $MONITOR_FOLDER; pwd`\""
else
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.MONITOR_FOLDER=monitor"
fi
if [ ! "$TEMP_FOLDER" = "" ] ;then
	mkdir -p "$TEMP_FOLDER"
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.TEMP_FOLDER=\"`cd $TEMP_FOLDER; pwd`\""
fi
if [ ! "$FEATUREPACKS_FOLDER" = "" ] ;then
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.featurepacks.dir=\"`cd $FEATUREPACKS_FOLDER; pwd`\""
	# The argument for featurepacks folder has changed name in TCC 11.
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.productpacks.dir=\"`cd $FEATUREPACKS_FOLDER; pwd`\""
fi

# Taleo endpoint configuration.
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.TALEO_HOST=\"$TALEO_HOST\""
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.TALEO_ZONE=\"${TALEO_HOST%.taleo.net}\""

# Proxy configuration.
JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyHost=\"$PROXY_HOST\""
JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyPort=\"$PROXY_PORT\""
JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyUser=\"$PROXY_USER\""
JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyPassword=\"$PROXY_PASSWORD\""
JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyNTDomain=\"$PROXY_NTDOMAIN\""

# File & folder configuration.
if [ ! "$2" = "" ] ;then
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.IN_FILE=\"`basename "$2"`\""
fi
if [ ! "$3" = "" ] ;then
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.OUT_FILE=\"`basename "$3"`\""
fi
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.INBOUND_FOLDER=\"$INBOUND_FOLDER\""
JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.client.symbol.OUTBOUND_FOLDER=\"$OUTBOUND_FOLDER\""

# Mail configuration.
if [ ! "$ALERTING_MAIL_FROM" = "" ] ;then
	JAVA_OPTS="$JAVA_OPTS -Dalerting.email.sender=\"$ALERTING_MAIL_FROM\""
fi

# Net-Change configuration.
if [ ! "$NETCHANGE_REPOSITORY" = "" ] ;then
	. ./core/Init_net-change.sh
	JAVA_OPTS="$JAVA_OPTS -Dcom.taleo.integration.client.extensions.plugins.configuration.dir.plugins.tcc-netchange=\"$NETCHANGE_CONFIG_FOLDER\""
fi

# Initialize RETRY_INDEX.
RETRY_INDEX=0

while [ ${RETRY_INDEX} -le ${NB_RETRIES} ] ;do
	# Run TCC
	eval "$JAVA_HOME/bin/java" $JAVA_OPTS -classpath $CLASSPATH com.taleo.integration.client.Client "$1" "$2" "$3"
	ERR=$?
		
	# Handle retries.
	if [ $ERR = 0 ] ;then
		break
	fi
  RETRY_INDEX=$(( ${RETRY_INDEX} + 1 ))
	if [ ${RETRY_INDEX} -le ${NB_RETRIES} ] ;then
		echo Retry ${RETRY_INDEX} of ${NB_RETRIES}
	fi
done

# Delete the NETCHANGE_CONFIG_FOLDER.
if [ -d "$NETCHANGE_CONFIG_FOLDER" ] ;then
	rm -rf "$NETCHANGE_CONFIG_FOLDER"
fi

# Handle errors
if [ $ERR -eq 0 ] ;then
	echo "###### SUCCESS ######"
else
	echo "#################################"
	echo "###### ERROR executing TCC ######"
	echo "#################################"
	exit $ERR
fi