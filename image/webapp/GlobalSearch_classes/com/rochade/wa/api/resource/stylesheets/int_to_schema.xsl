<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0"  indent="yes" /> <!-- encoding="UTF-8" -->

  <xsl:template match="/">  <a>
   <xsl:apply-templates select="/MIA_Results/row[1]" mode="a"/> 
   <xsl:apply-templates select="/MIA_Results/row[1]" mode="b"/> 
   </a>
  </xsl:template>
  
  <xsl:template match="row">  
     <xsl:apply-templates select="c"/>\n
  </xsl:template>
  
  <xsl:template match="c" mode="a">  
  <field type="string" indexed="true" stored="true" multiValued="no">
  <!-- sicherstellen in schema.xml, dass richtiger Sprach-Analyzer vorhanden ist -->
 <xsl:attribute name="type">
    <xsl:choose>
    <xsl:when test="@language=''">text_general</xsl:when>
    <xsl:when test="@language">text_<xsl:value-of select="@language"/></xsl:when>
    <xsl:otherwise>text_general</xsl:otherwise>
    </xsl:choose>
 </xsl:attribute>
 
  <xsl:attribute name="name"><xsl:value-of select="translate(@attr,
                                'abcdefghijklmnopqrstuvwxyz',
                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/><xsl:value-of select="@language"/></xsl:attribute>
  </field>
  </xsl:template>
  
  <xsl:template match="c" mode="b">  
    <field> 
    <xsl:attribute name="column"><xsl:number/></xsl:attribute>
    <!--  xsl:attribute name="column"><xsl:value-of select="@attr"/><xsl:value-of select="@language"/></xsl:attribute-->
    <xsl:attribute name="name"><xsl:value-of select="translate(@attr,
                                'abcdefghijklmnopqrstuvwxyz',
                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/><xsl:value-of select="@language"/></xsl:attribute>
  </field>
  </xsl:template>
     
</xsl:stylesheet>

