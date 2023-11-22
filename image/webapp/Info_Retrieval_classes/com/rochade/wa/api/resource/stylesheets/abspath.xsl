<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 1983-2023 Rocket Software, Inc. or its affiliates. All Rights Reserved. -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" version="1.0"  indent="yes" />

  <!-- *************************************************************************-->
  <!-- Root template -->
  <!-- *************************************************************************-->
  <!--  xsl:strip-space elements="*"/-->
  <xsl:template match="/">
    <!--  xsl:variable name="absPath_pos">
      <xsl:for-each select="/t/h/d">
        <xsl:if test="@n='absPath'">
          <xsl:value-of select="position()" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable-->
    
    <xsl:variable name="absPath_pos">
      <xsl:for-each select="/t/h/d">
        <xsl:if test="@t='ResultSet'">#<xsl:value-of select="position()" />#</xsl:if>
      </xsl:for-each>
    </xsl:variable>
     <xsl:apply-templates select="t">
      <xsl:with-param name="absPath_pos" select="$absPath_pos"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- *************************************************************************-->
  <!-- c template -->
  <!-- *************************************************************************-->
  <!-- Tranforms a column c 
       When column absPath is available then it converts it back to XML
  -->
  <xsl:template match="c">
    <xsl:param name="absPath_pos"></xsl:param>
    <xsl:variable name="actPos">#<xsl:number/>#</xsl:variable>
   
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="contains($absPath_pos,$actPos)">
           <xsl:value-of select="text()" disable-output-escaping="yes"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*|node()">
            <xsl:with-param name="absPath_pos" select="$absPath_pos"/>
          </xsl:apply-templates>          
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- *************************************************************************-->
  <!-- t template -->
  <!-- *************************************************************************-->

  <xsl:template match="t">
    <xsl:param name="absPath_pos"></xsl:param>
    <t>
      <java_com.rochade.wa.api.util.Replace file="businessTermMapping.xml"/>
      <java_com.rochade.wa.api.util.Replace file="myInfoAssistAttributes.xml"/>
      <java_com.rochade.wa.api.util.ReplaceCon/>
 
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="absPath_pos" select="$absPath_pos"/>
      </xsl:apply-templates>
    </t>
  </xsl:template>

  <!-- *************************************************************************-->
  <!-- copy template -->
  <!-- *************************************************************************-->

  <xsl:template match="@*|node()">
    <xsl:param name="absPath_pos"></xsl:param>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="absPath_pos" select="$absPath_pos"/>
   
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  

  
  <!--  xsl:template match="text()">
    <xsl:value-of select="." disable-output-escaping="yes"/>
  </xsl:template-->
  
  
</xsl:stylesheet>