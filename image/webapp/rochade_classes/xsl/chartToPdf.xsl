<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    	xmlns:svg="http://www.w3.org/2000/svg"
		xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:output method="xml" version="1.0"/>
<xsl:template match="/">
  <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Arial,'MS Gothic',sans-serif">
    <fo:layout-master-set>
     <fo:simple-page-master master-name="chart"
		    page-height="11in" page-width="8.5in" margin-top="50pt"
		    margin-bottom="50pt" margin-left="72pt" margin-right="72pt">
		    <fo:region-body margin-top="50pt" margin-bottom="50pt"/>
		    <fo:region-before region-name="before" extent="50pt" />
		    <fo:region-after region-name="after" extent="50pt" />
     </fo:simple-page-master>
   </fo:layout-master-set>
    <fo:page-sequence master-reference="chart">
      <fo:flow flow-name="xsl-region-body">
       	<fo:block text-align="center" font-size="24pt" space-after="20pt">
       		<xsl:value-of select="/root/title"/>
       	</fo:block>
        <fo:block text-align="left" >
        	<xsl:value-of select="/root/label"/>
        	<xsl:text> </xsl:text>
        	<xsl:value-of select="/root/dimension"/>
        </fo:block>
        <fo:block text-align="left">
        	<fo:instream-foreign-object><xsl:copy-of select="/root/chart/svg:svg"/></fo:instream-foreign-object>
        </fo:block>
        <fo:block text-align="left">
        	<fo:instream-foreign-object><xsl:copy-of select="/root/legend/svg:svg"/></fo:instream-foreign-object>
        </fo:block>
        <fo:block text-align="left" font-size="10pt">
        	<xsl:value-of select="/root/stamp"/>
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
  </fo:root>
</xsl:template>
</xsl:stylesheet>
