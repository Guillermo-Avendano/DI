<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 1983-2023 Rocket Software, Inc. or its affiliates. All Rights Reserved. -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

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
  <attributes>
     <!--  attribute attributeName="relates-to MIA" attribute="RBG/RELATES-TO" html="no" linkType="self"-->
    <attribute attributeName="relates-to WebAccess" attribute="RBG/RELATES-TO" html="no" linkType="WebAccess"/>
   
    <attribute attributeName="Synonym" attribute="RBG/SYNONYM-FOR"  linkType="RoBrowser"/>
    <attribute attributeName="Security Classification (c)" attribute="xxx"  linkType="RoBrowser"/>
    <!--  attribute attributeName="Definition 2" attribute="DEFINITION"/-->
  </attributes>
  <linkTypes>
    <linkType name="WebAccess">
      <href>http://localhost:8080/WebAccess/explorer/item.jsp?PATHINFO=/Rochade/AP-DATA/S/COLLEGE/INITIAL/NIL/NIL/NIL/0/0/$itemId</href>
    </linkType>
    <linkType name="RoBrowser">
      <href>
        http://localhost:8080/index.zul#item=$itemId!appid=!workspace=$workspace.mg.PROD!component=ObjectArea!navHide=true
      </href>
      <display>Link $name points to RoPlatform</display>
    </linkType>
    <linkType name="self">
      <href>#</href>
    </linkType>
  </linkTypes>
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

        <!-- All attributes of selected Business Term and c[position()=$type_pos]/text()='RBG/BUSINESS-TERM'-->
        <!-- ToDo: for special cases: Abspath: Ty-->
        <xsl:apply-templates select="/t/r[position()=1 and c[position()=$scopeAttr_pos]/text()='RBG/HAS-BUSINESS-TERM']/c"/>
        <!-- Parent context of selected Business Term -->
         <!-- start context path -->
         
         <!-- glossary -->
         <xsl:variable name="glossary" select="/t/r[position()=1 and c[position()=$scopeAttr_pos]/text()='RBG/HAS-BUSINESS-TERM']/c[position()=$absPath_pos]/t/r[position()=1]"/>
        <c attr="glossary" type="rir">
         <xsl:attribute name="language"><xsl:value-of select="$glossary/c[position()=5]/text()"/></xsl:attribute>
         <xsl:attribute name="type">link</xsl:attribute>  
        <xsl:value-of select="$glossary/c[position()=3]/text()"/></c>
        
         <!-- context  -->
        <xsl:if test="2 &lt; count(/t/r[position()=1 
          and c[position()=$scopeAttr_pos]/text()='RBG/HAS-BUSINESS-TERM']/c[position()=$absPath_pos]/t/r)">   
          <xsl:variable name="context" select="/t/r[position()=1 and c[position()=$scopeAttr_pos]/text()='RBG/HAS-BUSINESS-TERM']/c[position()=$absPath_pos]/t/r[position()=last()-1]"/>
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
        <c attr="acronyms" type="rir">
          <xsl:apply-templates select="/t/r[position()!=1 and c[position()=$type_pos]/text()='RBG/DESIGNATION']/c/t/r[position()=last()]/c[position()=3]" mode="synonym">
            <xsl:with-param name="count" select="count(/t/r[position()!=1 and c[position()=$type_pos]/text()='RBG/DESIGNATION'])"></xsl:with-param>      
          </xsl:apply-templates>
        </c>
        <!-- GlossaryID of selected Business Term -->
        <c attr="glossaryId" type="rir"><xsl:value-of select="/t/r[position()=1]/c/t/r[position()=1]/c[position()=1]/text()"/></c>
        
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
     <xsl:if test="position()&lt;$count">, </xsl:if>
  </xsl:template>
  
  <!-- *****************template match="r" mode="abspath************************* -->
  <!-- The shown hierarchical names reflect the name space structure 
       of the referenced artifact. -->
  <xsl:template match="r" mode="abspath">
    <xsl:param name="pos"/>
    <xsl:param name="count_r"/>
    
    <xsl:variable name="name"><xsl:value-of select="c[position()=3]/text()"/></xsl:variable>
    <xsl:variable name="type"><xsl:value-of select="c[position()=2]/text()"/></xsl:variable>
    
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


  <xsl:template match="c">
    <xsl:variable name="pos"><xsl:number/></xsl:variable>
    <!-- xsl:variable name="pos" select="position()"></xsl:variable-->
    <xsl:variable name="h0" select="parent::*/parent::*/h/d[position()=$pos]/@n"/>

   <xsl:element name="c">
        <xsl:attribute name="attr">
        <xsl:value-of select="$h0"/>
        </xsl:attribute>
         <xsl:apply-templates select="@*|node()|text()"/>
      </xsl:element>
      
  </xsl:template>
  
  <xsl:template match="@*|node()|text()">
    <xsl:param name="absPath_pos"></xsl:param>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()"/>       
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>