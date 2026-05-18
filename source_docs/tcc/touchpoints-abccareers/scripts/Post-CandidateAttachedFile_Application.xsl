<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"> 
  <xsl:output method="text" encoding="UTF-8"/> 
  <xsl:param name="delimiter">|</xsl:param> 
 
  <!-- ======================================= --> 
  <!-- Process the header. --> 
  <!-- ======================================= --> 
  <xsl:template match="/files"> 
    <!-- Header --> 
	
	<xsl:text>Username</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>EmailId</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>FirstName</xsl:text> 
    <xsl:value-of select="$delimiter"/>	
	<xsl:text>MiddleInitial</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>LastName</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>CandidateId</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<!--<xsl:text>RequisitionId</xsl:text> 
    <xsl:value-of select="$delimiter"/>-->
	<xsl:text>RecruitmentSource</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>AttachmentType</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>MimeType</xsl:text> 
    <xsl:value-of select="$delimiter"/>	
	
	<xsl:text>CreateDate</xsl:text> 
    <xsl:value-of select="$delimiter"/>		
	
	
	<!-- <xsl:text>AppStep</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>AppStatus</xsl:text> 
    <xsl:value-of select="$delimiter"/>-->
	<xsl:text>FileName2</xsl:text> 
	<xsl:value-of select="$delimiter"/>
    	
	 
	<!--<xsl:text>InternalApplication</xsl:text> 
    <xsl:value-of select="$delimiter"/>	 	
	<xsl:text>ProfileId</xsl:text> 
    <xsl:value-of select="$delimiter"/> 
	<xsl:text>ApplicationId</xsl:text> 
    <xsl:value-of select="$delimiter"/> 
	<xsl:text>ApplicationDate</xsl:text> 
    <xsl:value-of select="$delimiter"/> 
	
	<xsl:text>ReqState</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>AppStep</xsl:text> 
    <xsl:value-of select="$delimiter"/>
	<xsl:text>AppStatus</xsl:text> 
    <xsl:value-of select="$delimiter"/>	-->
	<xsl:text>Filepath</xsl:text> 
    <xsl:text>&#10;</xsl:text> 
	
	
    <!-- Rows --> 
    <xsl:apply-templates select="file"/> 
  </xsl:template> 
 
  <!-- ======================================= --> 
  <!-- Process rows. --> 
  <!-- ======================================= --> 
    <xsl:template match="file"> 
  
	<xsl:value-of select="Username"/>
	<xsl:value-of select="$delimiter"/>
	
	<xsl:value-of select="EmailId"/> 
    <xsl:value-of select="$delimiter"/>
	<xsl:value-of select="FirstName"/>
	<xsl:value-of select="$delimiter"/>
	<xsl:value-of select="MiddleInitial"/>
	<xsl:value-of select="$delimiter"/>
    <xsl:value-of select="LastName"/>
	<xsl:value-of select="$delimiter"/>
	<xsl:value-of select="CandidateId"/> 
    <xsl:value-of select="$delimiter"/>
   <!-- <xsl:value-of select="RequisitionId"/>
	<xsl:value-of select="$delimiter"/>-->
	<xsl:value-of select="RecruitmentSource"/> 
    <xsl:value-of select="$delimiter"/>
	<xsl:value-of select="AttachmentType"/> 
    <xsl:value-of select="$delimiter"/>

	<xsl:value-of select="MimeType"/> 
    <xsl:value-of select="$delimiter"/>

	<xsl:value-of select="CreateDate"/> 
    <xsl:value-of select="$delimiter"/>

	
	<!--<xsl:value-of select="AppStep"/>
	<xsl:value-of select="$delimiter"/>
    <xsl:value-of select="AppStatus"/>
	<xsl:value-of select="$delimiter"/>	-->
	<xsl:value-of select="FileName2"/>
	<xsl:value-of select="$delimiter"/>
     
    	
	<!-- <xsl:value-of select="Initial"/>
	<xsl:value-of select="$delimiter"/>
		
	 <xsl:value-of select="InternalApplication"/>
	<xsl:value-of select="$delimiter"/>
	 
	 <xsl:value-of select="ProfileId"/>
	<xsl:value-of select="$delimiter"/>
	<xsl:value-of select="ApplicationId"/>
	<xsl:value-of select="$delimiter"/>
	<xsl:value-of select="ApplicationDate"/>
	<xsl:value-of select="$delimiter"/>-->
   
    <xsl:value-of select="Filepath"/>
    <xsl:text>&#10;</xsl:text> 
  </xsl:template> 
</xsl:stylesheet>