<?xml version="1.0" encoding="UTF-8"?>
<!-- The stylesheet that overrides rsV2.xsl to support the proper <CONTEXTPATH> tag 
	configuration in old mode -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" indent="yes" />
	<xsl:include href="com/rochade/wa/api/resource/stylesheets/rsV2.xsl" />
	
	<!-- Select RBG/CONTEXT information into the <CONTEXTPATH> tag -->
	<xsl:template match="r">
		<row>
		<xsl:apply-templates select="c"/>
			<CONTEXTPATH>
				<xsl:value-of select="c[@attr='absPath']/t/r[position()=1]/c[@attr='name']/text()"/>
				<xsl:apply-templates select="c[@attr='absPath']/t/r[position()=2]" mode="abspath_part">
					<xsl:with-param name="pos" select="2"/>
					<xsl:with-param name="count_r" select="count(c[@attr='absPath']/t/r)"/>
					<xsl:with-param name="symbol"> &gt; </xsl:with-param>
					<xsl:with-param name="endPosition">1</xsl:with-param>
					<xsl:with-param name="start">false</xsl:with-param>
				</xsl:apply-templates>
			</CONTEXTPATH>
		</row>
	</xsl:template>

</xsl:stylesheet>