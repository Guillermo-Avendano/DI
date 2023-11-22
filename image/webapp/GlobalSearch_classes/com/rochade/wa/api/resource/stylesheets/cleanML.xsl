<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 1983-2023 Rocket Software, Inc. or its affiliates. All Rights Reserved. -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

  <xsl:template match="/">
  <xsl:variable name="workLang" select="/MIA_Results/@_WorkLang"></xsl:variable>
  <xsl:variable name="projectionLang" select="/MIA_Results/@_ProjectionLang"></xsl:variable>
    <xsl:apply-templates select="@*|node()|text()">
    <xsl:with-param name="workLang" select="$workLang"/>
    <xsl:with-param name="projectionLang" select="$projectionLang"/>
    </xsl:apply-templates>
  </xsl:template>
  
    <!--specific template match for c -->
  <xsl:template match="c[@attr='name' and (/MIA_Results/@_WorkLang!='' or /MIA_Results/@_ProjectionLang!='')]">
     <xsl:variable name="workLang" select="/MIA_Results/@_WorkLang"/>
   <xsl:variable name="projectionLang" select="/MIA_Results/@_ProjectionLang"/>
<!--  
   a <xsl:value-of select="/MIA_Results/@_WorkLang"/>
   b <xsl:value-of select="/MIA_Results/@_ProjectionLang"/>
   

-   d2 #<xsl:value-of select="contains($projectionLang,$workLang)"/>#
 -  d1 -<xsl:value-of select="not(contains($projectionLang,$workLang))"/>-
    - datal *<xsl:value-of select="@DataLang"/>*
    - $workLang '<xsl:value-of select="$workLang"/>'
     r <xsl:value-of select="@DataLang=$workLang and not(contains($projectionLang,$workLang))"/>-->
  <xsl:choose>
  <xsl:when test="@DataLang=$workLang and not(contains($projectionLang,$workLang))" >

  </xsl:when>
  <xsl:when test="@DataLang!=''" >

    <xsl:copy>        
        <xsl:apply-templates select="@*|node()|text()">
    </xsl:apply-templates>
      </xsl:copy>

   
  </xsl:when>
  <xsl:otherwise>


 <!--specific template match for this img -->

 <xsl:variable name="newAttr"><xsl:value-of select="@attr"/><xsl:value-of select="$workLang"/></xsl:variable>
 <xsl:variable name="workLang" select="/MIA_Results/@_WorkLang"></xsl:variable>
      <xsl:copy>
      <!-- Uncomment when the warning icon is needed -->
      <!-- The formatted xml file will look like  <c warn="true" attr="name">Cat</c> -->
      <!--  
      <xsl:choose>
       <xsl:when test="@attr='name'">
       <xsl:choose>
        <xsl:when test="parent::*/c[@attr='languages']/t/r[c[@attr='language']/text()=$workLang]/c[@attr='name']!=''"></xsl:when>
        <xsl:when test="parent::*/c[@attr='language']/text()=$workLang"></xsl:when>
        <xsl:otherwise><xsl:attribute name="warn">true</xsl:attribute></xsl:otherwise> 
       </xsl:choose>
       </xsl:when>
        <xsl:when test="@attr!='name' and @language!=$workLang">
          <xsl:attribute name="warn">true</xsl:attribute>
       </xsl:when>
       </xsl:choose>
        <xsl:if test="parent::*/c[@attr=$newAttr] and text()!=''">
          <xsl:attribute name="warn">true</xsl:attribute>
        </xsl:if>
          -->
        <xsl:apply-templates select="@*|node()|text()" >
    </xsl:apply-templates>
      </xsl:copy>
    <!--     - newAttr *<xsl:value-of select="$newAttr"/>*
       - test #<xsl:value-of select="parent::*/c[@attr=$newAttr]"/>#-->
 


  </xsl:otherwise>
  </xsl:choose>
  </xsl:template>
    
  <xsl:template match="@*|node()|text()">
    <xsl:param name="workLang"></xsl:param>

    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()">
    </xsl:apply-templates>     
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>