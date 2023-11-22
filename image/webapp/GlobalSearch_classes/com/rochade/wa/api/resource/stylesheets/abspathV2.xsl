<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:strip-space elements="*"/>
<xsl:output method="xml" version="1.0"  indent="yes" /> <!-- encoding="UTF-8" -->

  <xsl:template match="/">  
  <xsl:apply-templates select="t" mode="start"/> 
  </xsl:template>
  
  <xsl:template match="r">  
   <xsl:variable name="h" select="parent::*/h"/>
  
  <r>
  <xsl:apply-templates select="c | t"> 
  <xsl:with-param name="header" select="$h"></xsl:with-param>
  </xsl:apply-templates>
  </r>

  </xsl:template>
 
  <xsl:template match="c[text()!=''] | t">
   <xsl:param name="header"/>

  <xsl:variable name="pos" select="position()"></xsl:variable>
  <xsl:variable name="h0" select="$header/d[position()=$pos]/@n"/>
  <xsl:choose>
  <xsl:when test="h">

  <xsl:element name="c">
        <xsl:attribute name="attr">
        <xsl:value-of select="$h0"/>
        </xsl:attribute>
          <t>
        <xsl:apply-templates select="@*|node()|text()"/>
          </t>
      </xsl:element>      


  
  </xsl:when>
  <xsl:otherwise>
   <xsl:element name="c">
        <xsl:attribute name="attr">
        <xsl:value-of select="$h0"/>
        </xsl:attribute>
        <xsl:apply-templates select="@*|node()|text()"/>
      </xsl:element>      
  </xsl:otherwise>
  </xsl:choose>
     
   </xsl:template>
  <xsl:template match="t" mode="start">
    <t>
      <java_com.rochade.wa.api.util.Replace file="businessTermMapping.xml"/>
       <java_com.rochade.wa.api.util.Replace file="myInfoAssistAttributes.xml"/>
      <java_com.rochade.wa.api.util.ReplaceCon/> 
      <xsl:apply-templates select="@*|node()|text()"/>
    </t>
  </xsl:template>
  
   <xsl:template match="c[text()=''] | h">
  </xsl:template>
  
   <xsl:template match="@*|node()|text()">
    <xsl:param name="absPath_pos"></xsl:param>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
  </xsl:template>
    
</xsl:stylesheet>