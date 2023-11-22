<?xml version="1.0" encoding="UTF-8"?>
<!-- The stylesheet that overrides rsV2.xsl to support the proper language retrieval from certain RIM-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0"  indent="yes" /> 
<xsl:include href="com/rochade/wa/api/resource/stylesheets/rsV2.xsl"/>

  <xsl:template match="c">
   
  <xsl:if test="@attr='scopeId'">
      <xsl:element name="glossaryId">      
         <xsl:value-of select="parent::*/c[@attr='absPath']/t/r[position()=1]/c[@attr='id']/text()"/>
      </xsl:element>
      <xsl:element name="glossary">      
         <xsl:value-of select="parent::*/c[@attr='absPath']/t/r[position()=1]/c[@attr='name']/text()"/>
      </xsl:element>       
  </xsl:if>
  
  <!--  config of MyInfoAssist c' does not use XPATh expressions <xsl:value-of select="text()"/>-->
    
  <xsl:if test="@attr='name'">
  <!--  /t/Con/@_ProjectionLang" -->
  	<xsl:element name="name">
   
     <xsl:value-of select="."/><xsl:if test="/t/Con/@_WorkLang!=''"> [<xsl:value-of select="/t/Con/@_WorkLang"/>] </xsl:if>
     <xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@defaultLang and c[@attr='language']/text()!=/t/Con/@_WorkLang]"> <xsl:value-of select="c[@attr='name']"/> [<xsl:value-of select="c[@attr='language']"/>] </xsl:for-each>
   
     <xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()!=/t/Con/@defaultLang and c[@attr='language']/text()!=/t/Con/@_WorkLang and c[@attr='language']/text()!=/t/Con/@_WorkLang and contains(/t/Con/@_ProjectionLang, c[@attr='language']/text())]"> <xsl:value-of select="c[@attr='name']"/> [<xsl:value-of select="c[@attr='language']"/>] </xsl:for-each></xsl:element> 
  </xsl:if>
     
  <xsl:if test="@attr='glossaryId'">
       <xsl:element name="glossaryId"><xsl:value-of select="text()"/></xsl:element> 
  </xsl:if>
     
  <xsl:if test="@attr='id'">
       <xsl:element name="id">
        <xsl:value-of select="text()"/>
      </xsl:element>  
  </xsl:if>  
          
  <xsl:if test="@attr='type'">
       <xsl:element name="itemType">
       	<xsl:value-of select="text()"/>
      </xsl:element>  
  </xsl:if>
     
  <xsl:if test="@attr='DEFINITION'">
       <xsl:element name="DEFINITION">           
        <xsl:value-of select="text()"/>
  	   </xsl:element>  
  </xsl:if>
  
  <!-- Accepts all except <c attr="absPath"> node -->
  <!-- Add into result tree <c attr="languages"> node -->
  <xsl:if test="@attr!='absPath' "> 
     <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
  </xsl:if>
  
  </xsl:template>
    
</xsl:stylesheet>