<?xml version="1.0" encoding="UTF-8"?>
<!-- ======================================= -->
<!-- Parameterize a configuration file to use within TCC_Touchpoints. -->
<!-- ======================================= -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:cli="http://www.taleo.com/ws/integration/client">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:param name="CFGFOLDER"/>
	<!-- ======================================= -->
	<!-- Default template renders content as is. -->
	<!-- ======================================= -->
	<xsl:template match="@*|*|processing-instruction()|comment()">
		<xsl:copy>
			<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Replace all \ with / in text content, for Windows/Unix path compatibility. -->
	<!-- Replace the value of $CFGFOLDER passed as parameter with [CFGFOLDER]. -->
	<!-- ======================================= -->
	<xsl:template match="text()">
		<xsl:value-of select="replace(replace(., '\\', '/'), replace($CFGFOLDER, '\\', '/'), '[CFGFOLDER]/')"/>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the WorkflowIdentifier/Template from the ConfigurationIdentifier. -->
	<!-- ======================================= -->
	<xsl:template match="cli:WorkflowIdentifier/cli:Template">
		<xsl:copy>
			<xsl:value-of select="../../cli:ConfigurationIdentifier"/>_[NOW]_[LOOP_INDEX]</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the default endpoint. -->
	<!-- ======================================= -->
	<xsl:template match="cli:Process/cli:Send/cli:Endpoint">
		<xsl:copy>
			<xsl:attribute name="source" select="'DEFAULT'"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="//cli:Process/cli:Poll/cli:Endpoint">
		<xsl:copy>
			<xsl:attribute name="source" select="'DEFAULT'"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="//cli:Process/cli:Retrieve/cli:Endpoint">
		<xsl:copy>
			<xsl:attribute name="source" select="'DEFAULT'"/>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the TEMP_FOLDER if present. -->
	<!-- ======================================= -->
	<xsl:template match="cli:General/cli:TemporaryFilesFolder">
		<xsl:copy>[TEMP_FOLDER]</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the TEMP_FOLDER if absent -->
	<!-- ======================================= -->
	<xsl:template match="cli:General/cli:DeleteTemporaryFiles">
		<xsl:if test="not(../cli:TemporaryFilesFolder)">
			<cli:TemporaryFilesFolder>[TEMP_FOLDER]</cli:TemporaryFilesFolder>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the MONITORING. -->
	<!-- ======================================= -->
	<xsl:template match="cli:Monitoring">
		<xsl:copy>
			<cli:Folder>[MONITOR_FOLDER]</cli:Folder>
			<cli:FileName>
				<cli:SpecificName>
					<cli:Template>[TALEO_ZONE]_<xsl:value-of select="../cli:General/cli:ConfigurationIdentifier"/>_[NOW]_[LOOP_INDEX]</cli:Template>
				</cli:SpecificName>
			</cli:FileName>
			<cli:Type>
				<cli:HTML/>
				<cli:Text/>
			</cli:Type>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the email related symbols. -->
	<!-- ======================================= -->
	<xsl:template match="cli:Alerting/cli:Transports/cli:Email">
		<xsl:copy>
			<cli:Host>[MAIL_HOST]</cli:Host>
			<cli:Port>[MAIL_PORT]</cli:Port>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="cli:Alerting/cli:OnError">
		<xsl:copy>
			<cli:EmailAlert>
				<cli:Transport>
					<cli:To>[ALERTING_MAIL_ON_ERROR_TO]</cli:To>
					<cli:CC>[ALERTING_MAIL_ON_ERROR_CC]</cli:CC>
				</cli:Transport>
				<cli:Subject>
					<cli:Template>[TALEO_HOST]: TCC - <xsl:value-of select="../../cli:General/cli:ConfigurationIdentifier"/> - ERROR</cli:Template>
				</cli:Subject>
				<cli:Body>
					<cli:Text/>
				</cli:Body>
			</cli:EmailAlert>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="cli:Alerting/cli:OnComplete">
		<xsl:copy>
			<cli:EmailAlert>
				<cli:Transport>
					<cli:To>[ALERTING_MAIL_ON_COMPLETE_TO]</cli:To>
					<cli:CC>[ALERTING_MAIL_ON_COMPLETE_CC]</cli:CC>
				</cli:Transport>
				<cli:Subject>
					<cli:Template>[TALEO_HOST]: TCC - <xsl:value-of select="../../cli:General/cli:ConfigurationIdentifier"/> - Complete</cli:Template>
				</cli:Subject>
				<cli:Body>
					<cli:Text/>
				</cli:Body>
			</cli:EmailAlert>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the Net-Change thresholds. -->
	<!-- ======================================= -->
	<xsl:template match="cli:Parameter[cli:Name = 'Threshold for element update']/cli:Value">
		<xsl:copy>[NETCHANGE_UPDATE_THRESHOLD]</xsl:copy>
	</xsl:template>
	<xsl:template match="cli:Parameter[cli:Name = 'Threshold for element deletion']/cli:Value">
		<xsl:copy>[NETCHANGE_DELETE_THRESHOLD]</xsl:copy>
	</xsl:template>
	<xsl:template match="cli:Parameter[cli:Name = 'Threshold for element creation']/cli:Value">
		<xsl:copy>[NETCHANGE_CREATE_THRESHOLD]</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the FTP Get related symbols. -->
	<!-- ======================================= -->
	<xsl:template match="cli:CustomStep[cli:JavaClass = 'TCCPlugin:CCF5E756-F135-47F4-912D-53DC61C3E882']/cli:Parameters">
		<xsl:copy>
			<cli:Parameter>
				<cli:Name>Password</cli:Name>
				<cli:Value>[FTP_PASSWORD]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Host</cli:Name>
				<cli:Value>[FTP_HOST]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>File name</cli:Name>
				<cli:Value>[IN_FILE]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Remote path</cli:Name>
				<cli:Value>[FTP_INBOUND_FOLDER]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Transfer type</cli:Name>
				<cli:Value>ASCII</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Retry factor</cli:Name>
				<cli:Value>[FTP_RETRY_FACTOR]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Move folder</cli:Name>
				<cli:Value/>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Time between retries</cli:Name>
				<cli:Value>[FTP_RETRY_INTERVAL]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Move file</cli:Name>
				<cli:Value>false</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>User</cli:Name>
				<cli:Value>[FTP_USER]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Port</cli:Name>
				<cli:Value>[FTP_PORT]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Number of retries</cli:Name>
				<cli:Value>[FTP_RETRY_NUMBER]</cli:Value>
			</cli:Parameter>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the FTP Put related symbols. -->
	<!-- ======================================= -->
	<xsl:template match="cli:CustomStep[cli:JavaClass = 'TCCPlugin:153ff690-3c95-11dd-ae16-0800200c9a66']/cli:Parameters">
		<xsl:copy>
			<cli:Parameter>
				<cli:Name>Password</cli:Name>
				<cli:Value>[FTP_PASSWORD]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Host</cli:Name>
				<cli:Value>[FTP_HOST]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>File name</cli:Name>
				<cli:Value>[OUT_FILE]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Remote path</cli:Name>
				<cli:Value>[FTP_OUTBOUND_FOLDER]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Transfer type</cli:Name>
				<cli:Value>ASCII</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Retry factor</cli:Name>
				<cli:Value>[FTP_RETRY_FACTOR]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Time between retries</cli:Name>
				<cli:Value>[FTP_RETRY_INTERVAL]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>User</cli:Name>
				<cli:Value>[FTP_USER]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Port</cli:Name>
				<cli:Value>[FTP_PORT]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Number of retries</cli:Name>
				<cli:Value>[FTP_RETRY_NUMBER]</cli:Value>
			</cli:Parameter>
		</xsl:copy>
	</xsl:template>
	<!-- ======================================= -->
	<!-- Set the FTP Delete related symbols. -->
	<!-- ======================================= -->
	<xsl:template match="cli:CustomStep[cli:JavaClass = 'TCCPlugin:20a04170-3c95-11dd-ae16-0800200c9a66']/cli:Parameters">
		<xsl:copy>
			<cli:Parameter>
				<cli:Name>Password</cli:Name>
				<cli:Value>[FTP_PASSWORD]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Host</cli:Name>
				<cli:Value>[FTP_HOST]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>File name</cli:Name>
				<cli:Value>[IN_FILE]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Remote path</cli:Name>
				<cli:Value>[FTP_INBOUND_FOLDER]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Retry factor</cli:Name>
				<cli:Value>[FTP_RETRY_FACTOR]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Time between retries</cli:Name>
				<cli:Value>[FTP_RETRY_INTERVAL]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>User</cli:Name>
				<cli:Value>[FTP_USER]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Port</cli:Name>
				<cli:Value>[FTP_PORT]</cli:Value>
			</cli:Parameter>
			<cli:Parameter>
				<cli:Name>Number of retries</cli:Name>
				<cli:Value>[FTP_RETRY_NUMBER]</cli:Value>
			</cli:Parameter>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
