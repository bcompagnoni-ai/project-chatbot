<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================== -->
<!-- Read the value of a symbol in the configuration board. -->
<!-- ============================================== -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:cli="http://www.taleo.com/ws/integration/client">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:param name="name"/>
	<xsl:template match="/">
		<xsl:value-of select="/cli:BoardConfig/cli:Symbols/cli:Symbol[@name=$name]"/>
	</xsl:template>
</xsl:stylesheet>
