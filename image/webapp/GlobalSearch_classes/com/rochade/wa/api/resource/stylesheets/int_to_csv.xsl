<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" version="1.0"/> <!-- encoding="UTF-8" -->

<xsl:strip-space elements="*" />

  <xsl:template match="/">  
   <xsl:apply-templates select="/MIA_Results/row"/> 
  
  </xsl:template>
  
  <xsl:template match="row">
  
    <xsl:apply-templates select="c"/><xsl:apply-templates select="query/grid/Definition/object"/>\n
    
</xsl:template>
  
  <xsl:template match="c">
  
  <xsl:variable name="newtext">
  <xsl:call-template name="string-replace-all">
    <xsl:with-param name="text" select="normalize-space(.)" />
     <xsl:with-param name="replace">;</xsl:with-param>
    <xsl:with-param name="by">\\psmcomma\\</xsl:with-param>
  </xsl:call-template>
  </xsl:variable>
 
<xsl:value-of select="$newtext"/>;</xsl:template>

 <xsl:template match="object">
  <xsl:variable name="newtext">
  <xsl:call-template name="string-replace-all">
    <xsl:with-param name="text" select="normalize-space(@Name)" />
     <xsl:with-param name="replace">;</xsl:with-param>
    <xsl:with-param name="by">\\psmcomma\\</xsl:with-param>
  </xsl:call-template>
  </xsl:variable>
 
<xsl:value-of select="$newtext"/>;</xsl:template>


<xsl:template name="string-replace-all">
  <xsl:param name="text" />
  <xsl:param name="replace" />
  <xsl:param name="by" />
  <xsl:choose>
    <xsl:when test="contains($text, $replace)">
      <xsl:value-of select="substring-before($text,$replace)" />
      <xsl:value-of select="$by" />
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text"
        select="substring-after($text,$replace)" />
        <xsl:with-param name="replace" select="$replace" />
        <xsl:with-param name="by" select="$by" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>