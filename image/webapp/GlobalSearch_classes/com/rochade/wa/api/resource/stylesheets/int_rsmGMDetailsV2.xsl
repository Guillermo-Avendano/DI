<?xml version="1.0" encoding="UTF-8"?>
<!-- PSM -->
<!-- Peggy Schmidt-Mittenzwei -->
<!-- Copyright (c) 1983-2023 Rocket Software, Inc. or its affiliates. All Rights Reserved. -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
<!--   whatMin must contain attribute column! -->
  <xsl:template match="/">
    <MIA_Results>
    <!-- com.rochade.wa.api.util.XMLUtilities.transformXMLwithXSL(...) computes the connection parameters for the Rochade Browser -->
    <xsl:attribute name="application"><xsl:value-of select="/t/Con/@con"/></xsl:attribute>
    <xsl:attribute name="metaGlossary"><xsl:value-of select="/t/Con/@glossaryApplServer"/></xsl:attribute>
    <xsl:attribute name="roBrowser"><xsl:value-of select="/t/Con/@roBrowser"/></xsl:attribute>
    <xsl:attribute name="roDatabase"><xsl:value-of select="/t/Con/@roDatabase"/></xsl:attribute>
    <xsl:attribute name="componentType"><xsl:value-of select="/t/Con/@componentType"/></xsl:attribute>
      <xsl:attribute name="_WorkLang"><xsl:value-of select="/t/Con/@_WorkLang"/></xsl:attribute>
    <xsl:attribute name="_ProjectionLang"><xsl:value-of select="/t/Con/@_ProjectionLang"/></xsl:attribute>
    <xsl:attribute name="Pattern"><xsl:value-of select="/t/Con/@Pattern"/></xsl:attribute>
    <xsl:attribute name="Tags"><xsl:value-of select="/t/Con/@Tags"/></xsl:attribute>
    <xsl:attribute name="FitAllTags"><xsl:value-of select="/t/Con/@FitAllTags"/></xsl:attribute>
    <xsl:attribute name="Server"><xsl:value-of select="/t/Con/@Server"/></xsl:attribute>
     <xsl:attribute name="Scheme"><xsl:value-of select="/t/Con/@Scheme"/></xsl:attribute>
    <xsl:attribute name="Port"><xsl:value-of select="/t/Con/@Port"/></xsl:attribute>
    <xsl:attribute name="Appl"><xsl:value-of select="/t/Con/@Appl"/></xsl:attribute>
    <xsl:attribute name="SysLang"><xsl:value-of select="/t/Con/@_SysLang"/></xsl:attribute>
    <xsl:attribute name="defaultLang"><xsl:value-of select="/t/Con/@defaultLang"/></xsl:attribute>
    <xsl:apply-templates select="/t/Con/ProjectionLang"/>
    <xsl:apply-templates select="/t/Con/PLang"/>
 
  <xsl:apply-templates select="/t/myinfoAssistAttributes/attributes"></xsl:apply-templates>
  <xsl:apply-templates select="/t/myinfoAssistAttributes/linkAttributes"></xsl:apply-templates>
  <xsl:apply-templates select="/t/myinfoAssistAttributes/linkTypes"></xsl:apply-templates>
  
  <xsl:apply-templates select="/t/r[c[@attr='level']!='0']"></xsl:apply-templates>
  
  <xsl:for-each select="/t/r[c[@attr='level']='0']">
   <row>
      <xsl:if test="@attr='name' and @language=/t/Con/@_WorkLang">
          <c attr='name'><xsl:value-of select="text()"/></c>
        </xsl:if>
        
        <xsl:variable name="bt" select="self::*"/>

        <!-- All attributes of selected Business Term and c[@attr='type']/text()='RBG/BUSINESS-TERM'-->
        <!-- ToDo: for special cases: Abspath: Ty-->
        <xsl:apply-templates select="$bt/c"/>
        <!-- Parent context of selected Business Term -->
         <!-- start context path -->
         
         <!-- glossary GLOSSARYen -->
         <xsl:variable name="glossary" select="$bt/c[@attr='absPath']/t/r[position()=1]"/>
        <c attr="glossary">
        <!-- language available? -->
         <!--  xsl:attribute name="language"><xsl:value-of select="$glossary/c[@attr='nameGroup']/text()"/></xsl:attribute-->
         <xsl:attribute name="type">link</xsl:attribute>  
        <xsl:value-of select="$glossary/c[@attr='name']/text()"/></c>
        
         <!-- context  -->
         <xsl:choose>
        <xsl:when test="2 &lt; count($bt/c[@attr='absPath']/t/r)">   
          <xsl:variable name="abspath" select="$bt/c[@attr='absPath']/t"/>
          <xsl:variable name="context" select="$abspath/t/r[position()=last()-1]"/>
           <c attr="context">
           <xsl:attribute name="language"><xsl:value-of select="$context/c[position()=5]/text()"/></xsl:attribute>  
         <xsl:attribute name="type">link</xsl:attribute>  
         
          <xsl:value-of select="$context/c[position()=3]/text()"/></c>           
           <c attr="CONTEXTPATH">
          <!-- xsl:value-of select="$context/c[position()=3]/text()"/-->
           <xsl:apply-templates select="$abspath/r[position()=2]" mode="abspath_part">
            <xsl:with-param name="pos" select="2"/>
            <xsl:with-param name="count_r" select="count($abspath/r)"/>  
            <xsl:with-param name="symbol"> &gt; </xsl:with-param>
            <xsl:with-param name="endPosition">1</xsl:with-param>
            <xsl:with-param name="start">true</xsl:with-param>        
          </xsl:apply-templates>
      
         </c>
        </xsl:when>
        <xsl:otherwise>
          <c attr="context"/>
          <c attr="CONTEXTPATH"/></xsl:otherwise>
        </xsl:choose>
        
        <!-- context Path -->
       
         <!-- GlossaryID of selected Business Term -->
        <c attr="glossaryId"><xsl:value-of select="$glossary/c[@attr='id']/text()"/></c>
        
       
     <xsl:variable name="actPos"><xsl:number/></xsl:variable>
     <xsl:variable name="actPos2"><xsl:number/></xsl:variable>
    <xsl:for-each select="//PROJECTION_LANG">
      <c attr="acronyms">
          <xsl:attribute name="language"><xsl:value-of select="."/></xsl:attribute>
           <xsl:call-template name="subItems">
          <xsl:with-param name="pos"><xsl:value-of select="$actPos + 1"/></xsl:with-param>
          <xsl:with-param name="language" select="."></xsl:with-param>
        </xsl:call-template>
      </c>
    </xsl:for-each>
    
       
        
      <query>
        <grid>
          <Definition>
            <xsl:call-template name="queryGrid">
              <xsl:with-param name="pos"><xsl:value-of select="$actPos2 + 1"/></xsl:with-param>
            </xsl:call-template>
           </Definition>
         </grid>
        </query>
   </row>
  </xsl:for-each>
   
 
    </MIA_Results>
  </xsl:template>
  
  <xsl:template match="c" mode="synonym">
     <xsl:param name="count"></xsl:param>
     <xsl:value-of select="text()"/>
     <!--  xsl:if test="position()&lt;$count">, </xsl:if-->
  </xsl:template>
  
  
  <xsl:template name="subItems">
    <xsl:param name="pos"/>
    <xsl:param name="count_r"/>
    <xsl:param name="language"/>
       <xsl:variable name="item" select="/t/r[position()=$pos]"></xsl:variable>
      <!-- Synonyms of selected Business Term -->
        <!--  synonyms><xsl:apply-templates select="/t/r[position()!=1 and c[@attr='type']/text()='RBG/BUSINESS-TERM']/c/t/r[position()=last()]/c[position()=3]" mode="synonym"/></synonyms-->
        <!-- Acronyms of selected Business Term -->
        <xsl:if test="$item/c[@attr='type']/text()='RBG/DESIGNATION'">
          <xsl:for-each select="$item/c[@attr='languages']/t/r[c[@attr='name']/text()!='' and c[@attr='language']/text()=$language]">
            <xsl:value-of select="c[@attr='name']/text()"/>
          </xsl:for-each>
        </xsl:if>   
       
      <xsl:if test="$item/c[@attr='level']!='0'">
        <xsl:call-template name="subItems">
          <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
        </xsl:call-template>
      </xsl:if>
 </xsl:template>  
 
 <xsl:template name="queryGrid">
    <xsl:param name="pos"/>
    <xsl:param name="count_r"/>
   <xsl:variable name="aaa" select="/t/r[position()=$pos]"></xsl:variable>
      <xsl:if test="$aaa/c[@attr='level']!='0' and $aaa/c[@attr='attribute']/text()='RBG/REFERENCES'">
                <xsl:apply-templates select="/t/r[position()=$pos]/c[@attr='absPath']/t/r[position()=1]" mode="abspath">
                  <xsl:with-param name="pos" select="1"/>
                  <xsl:with-param name="count_r" select="count($aaa/c[@attr='absPath']/t/r)"/>
                  <xsl:with-param name="id" select="$aaa/c[@attr='id']"/>
                </xsl:apply-templates>                
    </xsl:if> 
    
    <xsl:if test="$aaa/c[@attr='level']!='0'">
        <xsl:call-template name="queryGrid">
     <xsl:with-param name="pos"><xsl:value-of select="$pos + 1"/></xsl:with-param>
     </xsl:call-template>
    </xsl:if> 
    
    
 </xsl:template>  
  <!-- *****************template match="r" mode="abspath************************* -->
  <!-- The shown hierarchical names reflect the name space structure 
       of the referenced artifact. -->
  <xsl:template match="r" mode="abspath">
    <xsl:param name="pos"/>
    <xsl:param name="count_r"/>
    <xsl:param name="id"/>
    
    <xsl:variable name="name"><xsl:value-of select="c[@attr='name']/text()"/></xsl:variable>
    <xsl:variable name="type"><xsl:value-of select="c[@attr='type']/text()"/></xsl:variable>
    
    <!-- A business name will be presented, if a business name is not available, the physical item name will be used. -->
    <xsl:variable name="typeName">
    <xsl:choose>
        <xsl:when test="/t/Job/Transformation/Variables/Var[@Name=$name and @Type=$type]/@Name=c[position()=3]/text()"><xsl:value-of select="/t/Job/Transformation/Variables/Var[@Name=$name and @Type=$type]/@Value"/></xsl:when>
        <xsl:otherwise>
         <xsl:choose>
            <xsl:when test="/t/Job/Transformation/Variables/Var[@Name=$name]/@Name=c[position()=3]/text()"><xsl:value-of select="/t/Job/Transformation/Variables/Var[@Name=$name]/@Value"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="c[position()=3]/text()"/></xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <object>     
      <!-- ***** Type ******** -->
      <xsl:attribute name="Type">
      <xsl:choose>
        <xsl:when test="/t/Job/ListAsGroup/Type[@name=$type]"><xsl:value-of select="$typeName"/></xsl:when>
        <xsl:otherwise>Others</xsl:otherwise>
      </xsl:choose>
      </xsl:attribute>
      
       <xsl:attribute name="TypeId">
      <xsl:choose>
        <xsl:when test="/t/Job/ListAsGroup/Type[@name=$type]"><xsl:value-of select="c[position()=1]/text()"/></xsl:when>
        <xsl:otherwise>Others</xsl:otherwise>
      </xsl:choose>
      </xsl:attribute>
      
      <!-- ***** Name ******** -->
      <xsl:attribute name="Name">
        <xsl:value-of select="$typeName"/>
        <xsl:if test="$pos!=$count_r + 1">
          <xsl:apply-templates select="parent::*/r[position()=$pos + 1]" mode="abspath_part">
            <xsl:with-param name="pos" select="$pos + 1"/>
            <xsl:with-param name="count_r" select="$count_r"/>
            <xsl:with-param name="symbol">.</xsl:with-param> 
            <xsl:with-param name="endPosition">0</xsl:with-param>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:attribute>
      
      <!-- ***** ItemId of RBG/REFERENCED Object ******** -->
      <xsl:attribute name="ItemId"> <xsl:value-of select="$id"/>
        <!--  xsl:value-of select="parent::*/r[position()=$count_r]/c[@attr='id']/text()"/-->
      </xsl:attribute>
    </object>
  </xsl:template>

  <xsl:template match="r" mode="abspath_part">
    <xsl:param name="pos"/>
    <xsl:param name="count_r"/>
    <xsl:param name="symbol"/>
    <xsl:param name="endPosition"/>
    <xsl:param name="start"/>
    <xsl:if test="$start!='true'"><xsl:value-of select="$symbol"/></xsl:if> <xsl:value-of select="c[position()=3]/text()"/>
    <xsl:if test="$pos + $endPosition &lt; $count_r ">
      <xsl:apply-templates select="parent::*/r[position()=$pos + 1]" mode="abspath_part">
        <xsl:with-param name="pos" select="$pos + 1"/>
        <xsl:with-param name="count_r" select="$count_r"/>
        <xsl:with-param name="symbol"><xsl:value-of select="$symbol"/></xsl:with-param>
         <xsl:with-param name="endPosition"><xsl:value-of select="$endPosition"/></xsl:with-param>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

<xsl:template match="c[@attr='name']"> 

<xsl:choose>
<xsl:when test="c[@attr='languages']"></xsl:when>
<xsl:otherwise>
  <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
</xsl:otherwise>
</xsl:choose>
   <!--  PSM 2013-10-21 -->
   <!--  PSM 2014-01-09 -->
   
   </xsl:template>
   
  <xsl:template match="c[@attr='languages']">
   <xsl:apply-templates select="t/r" mode="languages"/>
 
   </xsl:template>
   
   <xsl:template match="r" mode="languages">  
    <c attr="name">
       <xsl:attribute name="language"><xsl:value-of select="c[@attr='language']/text()"/></xsl:attribute>
     <xsl:value-of select="c[@attr='name']/text()"/>
         </c>   
   </xsl:template>
     
  <xsl:template match="c">
   <xsl:choose>
   <xsl:when test="contains(/t/Con/whatStylesheet/text(),@attr)"></xsl:when>
   <xsl:otherwise>
   <!-- EDI-8591 create tag for attribute even if it has no value (e.g. DEFINITIONfr has no value for current item)
   If not doing so, the detail view of MIA for the item will display the no-language variation value for the DEFINITION attribute (so often it will be English)
   even if MIA requested to show only the French value of attributes (because the user has searched only for French as target language)
   <xsl:if test="text()!='' or t">
   -->
     <xsl:copy>
       <xsl:apply-templates select="@*|node()|text()"/>
     </xsl:copy>
    <!--
     </xsl:if>
    -->
   </xsl:otherwise>
   
   </xsl:choose>
  </xsl:template>
  
   <xsl:template match="h">
   </xsl:template>
  
  <xsl:template match="@*|node()|text()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>