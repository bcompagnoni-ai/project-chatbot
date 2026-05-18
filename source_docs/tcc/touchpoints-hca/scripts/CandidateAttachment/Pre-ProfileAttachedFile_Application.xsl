<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:ns="http://www.taleo.com/ws/integration/toolkit/2005/07" 
xmlns:fct="http://www.taleo.com/xsl_functions" 
exclude-result-prefixes="ns fct">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:param name="OUTBOUND_FOLDER"/>

  <!-- ======================================= -->
  <!-- Root template. -->
  <!-- ======================================= -->
  <xsl:template match="/">
    <files>
      <xsl:apply-templates select="//ns:record"/>
    </files>
  </xsl:template>

  <!-- ======================================= -->
  <!-- Process each document. -->
  <!-- ======================================= -->
  <xsl:template match="ns:record">

 
    <!-- Set variables. --> 
	<!--<xsl:variable name="RequisitionId" select="ns:field[@name = 'RequisitionId']"/>-->
    <xsl:variable name="CandidateId" select="ns:field[@name = 'CandidateId']"/>
    <xsl:variable name="EmailId" select="ns:field[@name = 'EmailId']"/> 	
	<xsl:variable name="FirstName" select="ns:field[@name = 'FirstName']"/>
	<xsl:variable name="MiddleInitial" select="ns:field[@name = 'MiddleInitial']"/>
	<xsl:variable name="LastName" select="ns:field[@name = 'LastName']"/>
	<xsl:variable name="Username" select="ns:field[@name = 'Username']"/>
	<xsl:variable name="RecruitmentSource" select="ns:field[@name = 'RecruitmentSource']"/>
	<xsl:variable name="AttachmentType" select="ns:field[@name = 'AttachmentType']"/>
	<xsl:variable name="MimeType" select="ns:field[@name = 'MimeType']"/>	
	<xsl:variable name="CreateDate" select="ns:field[@name = 'CreateDate']"/>		
	

	<!-- <xsl:variable name="AppStep" select="ns:field[@name = 'AppStep']"/>
	<xsl:variable name="AppStatus" select="ns:field[@name = 'AppStatus']"/> -->
	<!-- <xsl:variable name="InternalApplication" select="ns:field[@name = 'InternalApplication']"/>
	<xsl:variable name="RequisitionId" select="ns:field[@name = 'RequisitionId']"/>
	<xsl:variable name="ProfileId" select="ns:field[@name = 'ProfileId']"/>
	<xsl:variable name="ApplicationId" select="ns:field[@name = 'ApplicationId']"/>
	<xsl:variable name="ApplicationDate" select="ns:field[@name = 'ApplicationDate']"/> -->
	<xsl:variable name="FileName" select="ns:field[@name = 'FileName']"/>
	<xsl:variable name="FileName2" select="fct:normalize-filename(concat($CandidateId,'~',$FileName))"/>
	<!--<xsl:variable name="FileName2" select="fct:normalize-filename($FileName)"/>-->
	<xsl:variable name="Filepath" select="(concat($OUTBOUND_FOLDER, '/', fct:normalize-filename($FileName2)))"/>
	
	
    <!-- Build the file element. --> 
	<file path="{concat($OUTBOUND_FOLDER, '/', fct:normalize-filename($FileName2))}"> 
	 <content> 
        <xsl:value-of select="ns:field[@name = 'AttachedFilesFileContent']"/> 
      </content> 
	   <CandidateId> 
        <xsl:value-of select="$CandidateId"/> 
      </CandidateId>
	  <EmailId>
	    <xsl:value-of select="$EmailId"/>
	  </EmailId>
		<FirstName> 
        <xsl:value-of select="$FirstName"/> 
      </FirstName>
	  
	  <MiddleInitial> 
        <xsl:value-of select="$MiddleInitial"/> 
      </MiddleInitial>
	  
	  <LastName> 
        <xsl:value-of select="$LastName"/> 
      </LastName>
	  <Username>
	    <xsl:value-of select="$Username"/>
	  </Username>
	  <!-- <InternalApplication> 
        <xsl:value-of select="$InternalApplication"/> 
      </InternalApplication> -->
	  
	 <!-- <RequisitionId> 
        <xsl:value-of select="$RequisitionId"/> 
      </RequisitionId>-->
	 <RecruitmentSource> 
        <xsl:value-of select="$RecruitmentSource"/> 
      </RecruitmentSource>
	 
	 <AttachmentType> 
        <xsl:value-of select="$AttachmentType"/> 
      </AttachmentType>
	  
	 <MimeType> 
        <xsl:value-of select="$MimeType"/> 
      </MimeType>	  

	 <CreateDate> 
        <xsl:value-of select="$CreateDate"/> 
      </CreateDate>	

	  
	  <!--<AppStep> 
        <xsl:value-of select="$AppStep"/> 
      </AppStep>
	  <AppStatus> 
        <xsl:value-of select="$AppStatus"/> 
      </AppStatus> -->
	  
	  
	  
	  <!-- <ProfileId> 
        <xsl:value-of select="$ProfileId"/> 
      </ProfileId>
	   <ApplicationId> 
        <xsl:value-of select="$ApplicationId"/> 
      </ApplicationId>
	   <ApplicationDate> 
        <xsl:value-of select="$ApplicationDate"/> 
      </ApplicationDate> -->
	  <FileName> 
        <xsl:value-of select="$FileName"/> 
      </FileName>
	  <FileName2> 
        <xsl:value-of select="$FileName2"/> 
      </FileName2>
	  <Filepath> 
        <xsl:value-of select="$Filepath"/> 
      </Filepath>
    </file> 
  </xsl:template> 
   <!-- ======================================= --> 
  <!-- Normalize filename, replacing invalid characters with '_'. --> 
  <!-- ======================================= --> 
  <xsl:function name="fct:normalize-filename"> 
    <xsl:param name="filename"/> 
    <xsl:value-of select="replace(replace(translate($filename, '\\\/:*?|', '_'), '&lt;', '_'), '&gt;', '_')"/> 
  </xsl:function> 
</xsl:stylesheet>