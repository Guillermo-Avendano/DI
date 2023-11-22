<?xml version="1.0" encoding="UTF-8"?>
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
    <xsl:attribute name="defaultLang"><xsl:value-of select="/t/Con/@defaultLang"/></xsl:attribute>
  <xsl:apply-templates select="/t/myinfoAssistAttributes/attributes"></xsl:apply-templates>
  <xsl:apply-templates select="/t/myinfoAssistAttributes/linkAttributes"></xsl:apply-templates>
  <xsl:apply-templates select="/t/myinfoAssistAttributes/linkTypes"></xsl:apply-templates>
  <xsl:for-each select="/t/Con/ProjectionLang"><xsl:apply-templates select="self::*"/></xsl:for-each>
      <row>
        <xsl:variable name="type_pos" >
          <xsl:for-each select="t/h/d">
            <xsl:if test="@n='type'">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="level_pos" >
          <xsl:for-each select="t/h/d">
            <xsl:if test="@n='level'">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="name_pos" >
          <xsl:for-each select="t/h/d">
            <xsl:if test="@n='name'">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="id_pos" >
          <xsl:for-each select="t/h/d">
            <xsl:if test="@n='id'">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="scopeAttr_pos" >
          <xsl:for-each select="t/h/d">
            <xsl:if test="@n='scopeAttribute'">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="absPath_pos">
          <xsl:for-each select="/t/h/d">
            <xsl:if test="@n='absPath'">
              <xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="attribute_pos">
          <xsl:for-each select="/t/h/d">
            <xsl:if test="@n='attribute'">
              <xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:if test="@attr='name' and @language=/t/Con/@_WorkLang">
          <c attr='name'><xsl:value-of select="text()"/></c>
        </xsl:if>
        
        <xsl:variable name="bt" select="/t/r[position()=1 and c[@attr='scopeAttribute']/text()='RBG/HAS-BUSINESS-TERM']"/>

        <!-- All attributes of selected Business Term and c[position()=$type_pos]/text()='RBG/BUSINESS-TERM'-->
        <!-- ToDo: for special cases: Abspath: Ty-->
        <xsl:apply-templates select="$bt/c"/>
        <!-- Parent context of selected Business Term -->
         <!-- start context path -->
         
         <!-- glossary -->
         <xsl:variable name="glossary" select="$bt/c[@attr='absPath']/t/r[position()=1]"/>
        <c attr="glossary" type="rir">
        <!-- language available? -->
         <xsl:attribute name="language"><xsl:value-of select="$glossary/c[@attr='nameGroup']/text()"/></xsl:attribute>
         <xsl:attribute name="type">link</xsl:attribute>  
        <xsl:value-of select="$glossary/c[position()=3]/text()"/></c>
        
         <!-- context  -->
        <xsl:if test="2 &lt; count($bt/c[@attr='absPath']/t/r)">   
          <xsl:variable name="context" select="$bt/c[@attr='absPath']/t/r[position()=last()-1]"/>
           <c attr="context">
           <xsl:attribute name="language"><xsl:value-of select="$context/c[position()=5]/text()"/></xsl:attribute>  
         <xsl:attribute name="type">link</xsl:attribute>  
         
          <xsl:value-of select="$context/c[position()=3]/text()"/></c>
          
           <c attr="CONTEXTPATH" type="rir">
          <xsl:value-of select="$context/c[position()=3]/text()"/>
           <!--  xsl:apply-templates select="/t/r[position()=1 and c[position()=$scopeAttr_pos]/text()='RBG/HAS-BUSINESS-TERM']/c[position()=$absPath_pos]/t/r[position()=2]" mode="abspath_part">
            <xsl:with-param name="pos" select="2"/>
            <xsl:with-param name="count_r" select="count(/t/r[position()=1]/c/t/r)"/>  
            <xsl:with-param name="symbol">&gt;</xsl:with-param>
            <xsl:with-param name="endPosition">1</xsl:with-param>
            <xsl:with-param name="start">true</xsl:with-param>        
          </xsl:apply-templates-->
      
         </c>
        </xsl:if>
        
        <!-- context Path -->
       
         
        <!-- Synonyms of selected Business Term -->
        <!--  synonyms><xsl:apply-templates select="/t/r[position()!=1 and c[position()=$type_pos]/text()='RBG/BUSINESS-TERM']/c/t/r[position()=last()]/c[position()=3]" mode="synonym"/></synonyms-->
        <!-- Acronyms of selected Business Term -->
        <xsl:variable name="acronym" select="/t/r[position()!=1 and c[position()=$type_pos]/text()='RBG/DESIGNATION']"/>
        
        <!-- default language -->
        <c attr="acronyms" >
          <xsl:apply-templates select="$acronym/c/t/r[position()=last()]/c[position()=3]" mode="synonym">
            <xsl:with-param name="count" select="count(/t/r[position()!=1 and c[position()=$type_pos]/text()='RBG/DESIGNATION'])"></xsl:with-param>      
            <xsl:with-param name="language" select="@language"/>
          </xsl:apply-templates>
        </c>
        
        <!--generate acronyms for all specific languages-->
        <xsl:for-each select="/t/r[position()=1]/c[@attr='languages']/t/r">
        
        <xsl:variable name="l" select="c[@attr='language']/text()"/>
        <c attr="acronyms">
          <xsl:attribute name="language"><xsl:value-of select="$l"/></xsl:attribute>
          <xsl:apply-templates select="$acronym/c[@attr='languages']/t/r[c[@attr='language']/text()=$l and (contains(/t/Con/@_ProjectionLang,$l) or contains(/t/Con/@_WorkLang,$l)) ]/c[@attr='name']" mode="synonym">
            <xsl:with-param name="count" select="count(/t/r[position()!=1 and c[position()=$type_pos]/text()='RBG/DESIGNATION'])"></xsl:with-param>      
            <xsl:with-param name="language" select="@language"/>
          </xsl:apply-templates>
        </c>
        </xsl:for-each>
        <!-- GlossaryID of selected Business Term -->
        <c attr="glossaryId" type="rir"><xsl:value-of select="/t/r[position()=1]/c/t/r[position()=1]/c[position()=1]/text()"/></c>
         <c attr="EIM_META_NOTE"><t>
   <xsl:for-each select="/t/r[c/@attr='type' and c/text()='EIM_META_NOTE']">
    <r>
      <c attr='name'><xsl:value-of select="c[@attr='DEFINITION']"/></c>
      <c attr='id'><xsl:value-of select="c[@attr='id']"/></c>
    </r>
   
   </xsl:for-each>
   </t></c>
        <query>
          <grid>
            <Definition>
              <xsl:for-each select="/t/r[c[position()=$attribute_pos]/text()='RBG/REFERENCES']/c[position()=$absPath_pos]">
                
                <xsl:apply-templates select="t/r[position()=1]" mode="abspath">
                  <xsl:with-param name="pos" select="1"/>
                  <xsl:with-param name="count_r" select="count(t/r)"/>
                </xsl:apply-templates>
              </xsl:for-each>

            </Definition>
          </grid>
        </query>
      </row>
    </MIA_Results>
  </xsl:template>
  
  <xsl:template match="c" mode="synonym">
     <xsl:param name="count"></xsl:param>
     <xsl:value-of select="text()"/>
     <!--  xsl:if test="position()&lt;$count">, </xsl:if-->
  </xsl:template>
  
  
  <!-- *****************template match="r" mode="abspath************************* -->
  <!-- The shown hierarchical names reflect the name space structure 
       of the referenced artifact. -->
  <xsl:template match="r" mode="abspath">
    <xsl:param name="pos"/>
    <xsl:param name="count_r"/>
    
    <xsl:variable name="name"><xsl:value-of select="c[@attr='name']/text()"/></xsl:variable>
    <xsl:variable name="type"><xsl:value-of select="c[@attr='type']/text()"/></xsl:variable>
    
    <!-- A business name will be presented, if a business name is not available, the physical item name will be used. -->
    <xsl:variable name="typeName">
    <xsl:choose>
        <xsl:when test="/t/Job/Transformation/Variables/Var[@Name=$name and @Type=$type]/@Name=c[@attr='name']/text()"><xsl:value-of select="/t/Job/Transformation/Variables/Var[@Name=$name and @Type=$type]/@Value"/></xsl:when>
        <xsl:otherwise>
         <xsl:choose>
            <xsl:when test="/t/Job/Transformation/Variables/Var[@Name=$name]/@Name=c[@attr='name']/text()"><xsl:value-of select="/t/Job/Transformation/Variables/Var[@Name=$name]/@Value"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="c[@attr='name']/text()"/></xsl:otherwise>
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
      <xsl:attribute name="ItemId">
        <xsl:value-of select="parent::*/r[position()=$count_r]/c[position()=1]/text()"/>
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
   <!--  PSM 2013-10-21 -->
     <c attr="name" language="">
     
     <xsl:value-of select="."/><xsl:if test="/t/Con/@_WorkLang!=''"> [<xsl:value-of select="/t/Con/@_WorkLang"/>] </xsl:if>
     <xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@defaultLang and c[@attr='language']/text()!=/t/Con/@_WorkLang]"> <xsl:value-of select="c[@attr='name']"/> [<xsl:value-of select="c[@attr='language']"/>] </xsl:for-each>
   
     <xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()!=/t/Con/@defaultLang and c[@attr='language']/text()!=/t/Con/@_WorkLang and c[@attr='language']/text()!=/t/Con/@_WorkLang and contains(/t/Con/@_ProjectionLang, c[@attr='language']/text())]"> <xsl:value-of select="c[@attr='name']"/> [<xsl:value-of select="c[@attr='language']"/>] </xsl:for-each> </c>
 
   <!-- 
   <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
   <xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()!=/t/Con/@_WorkLang and contains(/t/Con/@_ProjectionLang, c[@attr='language']/text())]">
    <c attr="name">
    
    <xsl:attribute name="language"><xsl:value-of select="c[@attr='language']"/></xsl:attribute>
    <xsl:value-of select="c[@attr='name']"/>
    </c>
   
   </xsl:for-each>-->
   
   
  
  </xsl:template>
  
  <xsl:template match="@*|node()|text()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>