<?xml version="1.0" encoding="UTF-8"?>
<!-- NK -->
<!-- Copyright (c) 1983-2023 Rocket Software, Inc. or its affiliates. All Rights Reserved. -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  extension-element-prefixes="exsl">

  <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" />
  
  <xsl:template match="/">
    { 
      "response" : {
        "numFound" : <xsl:value-of select="count(/MIA_Results/row)" />,
        "numRetrieved" : <xsl:value-of select="count(/MIA_Results/row)" />,
        "start": 0,
        "startPaging": 0,
        "docs": [
          <xsl:apply-templates select="/MIA_Results/row" />
          ]
        } 
    }
  </xsl:template>

  <xsl:template match="row">
          { <xsl:apply-templates select="c"/> }<xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
  </xsl:template>
  
  <xsl:template match="c">
    <xsl:variable name="attr">
		<xsl:choose>
			<!-- After converting the ResultSet to XML (see ResultSet.toXML(ResultSet.RESULTSET_XSD_2_0))
			if the column is clearly identified as multi-valued language attribute (e.g. the 'name' attribute),
			then converts to upper case (because user guides let think that every attribute should be upper case
			except the 'language' suffix) -->
			<xsl:when test="@language">
				<xsl:value-of select="translate(@attr,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/><xsl:value-of select="@language"/>      
			</xsl:when>
			<!-- but keep original case for other columns not properly merged as the multiple-language values of the same attribute
			(e.g. DEFINITIONen, DEFINITIONde, DEFINITIONfr columns are NOT merged by ResultSet.toXML(ResultSet.RESULTSET_XSD_2_0)
			as the 'en', 'de' and 'fr' versions of the same 'DEFINITION' attribute).
			
			Previously (i.e. before 8.80 release) InsertToLuceneIndex.extractJSONData() was expecting the exact case
			with the mapping rules defined into MGSolrInsert.xml (e.g. <field column="TYPE" name="type"/> what meant
			that the Rochade type attribute should be written 'TYPE' but not 'type').
			However converting everything to upper-case was causing trouble for language-version of an attribute
			'DEFINITIONde' is not the same as 'DEFINITIONDE'.
			Since it is hard to create a smart transformation rule that decides to upper-case 'type'
			but that lets 'DEFINITIONde' as it (for example: do we have to uppercase or not 'eim_meta_note'
			because 'te' is the ISO code the Telugu language so maybe the attribute name is in fact 'EIM_META_NO'
			in Telugu?) we decided that InsertToLuceneIndex.extractJSONData() should now also supports
			case-insensitive mapping as a second-chance if a case-sensitive match cannot be found during a first-pass.
			-->
			<xsl:otherwise>
				<xsl:value-of select="@attr"/> 
			</xsl:otherwise>
		</xsl:choose>
    </xsl:variable>
        
	<xsl:choose>
		<xsl:when test="t/r/c[@attr='name']"><!-- the attribute contains multiple values (probably because the Rochade attribute returned a ResultSet). Those values are stored in t/r/c descendants -->
			<xsl:variable name="escapedName">
				<xsl:call-template name="escape-json">
					<xsl:with-param name="text" select="$attr" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:text>&#13;&#10;</xsl:text> <!-- newline character -->
			<xsl:text>"</xsl:text><xsl:value-of select="$escapedName"/><xsl:text>":[</xsl:text>
			<xsl:for-each select="t/r/c[@attr='name']">
				<xsl:variable name="escapedValue">
					<xsl:call-template name="escape-json">
						<xsl:with-param name="text" select="normalize-space(string(.))" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$escapedValue!=''">
					<xsl:text>"</xsl:text><xsl:value-of select="$escapedValue"/><xsl:text>"</xsl:text>
					<xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
			<xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
		</xsl:when>
		<xsl:otherwise> <!-- basic attribute which the value is stored directly a Text node child -->
		    <xsl:call-template name="Properties">
		       <xsl:with-param name="name" select="$attr" />
		       <xsl:with-param name="value" select="string(.)" />
		       <xsl:with-param name="isNotLast" select="position() != last()" />
		    </xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <xsl:template match="c" mode="ArrayElement">
    <xsl:param name="name" />
    <xsl:choose>
      <xsl:when test="@attr='id'"> 
        "<xsl:value-of select="$name"/>": "<xsl:value-of select="."/>",
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="object">
    <xsl:call-template name="Properties">
       <xsl:with-param name="name" select="@Name" />
       <xsl:with-param name="value" select="@ItemId" />
       <xsl:with-param name="isNotLast" select="position() != last()" />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="Properties">    
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:param name="isNotLast" />
    <xsl:variable name="childName" select="name(*[1])"/>
    
    
    <xsl:choose>
      <xsl:when test="string($childName)">
     <!--    <xsl:value-of select="r"></xsl:value-of>
        <xsl:apply-templates select="*" mode="ArrayElement">
          <xsl:with-param name="name" select="$name" />
        </xsl:apply-templates> -->
      </xsl:when>
      <xsl:otherwise>
          <xsl:variable name="escapedName">
             <xsl:call-template name="escape-json">
               <xsl:with-param name="text" select="$name" />
            </xsl:call-template>
          </xsl:variable> 
          <xsl:variable name="escapedValue">
             <xsl:call-template name="escape-json">
               <xsl:with-param name="text" select="normalize-space($value)" />
            </xsl:call-template>
          </xsl:variable> 
            "<xsl:value-of select="$escapedName"/>":"<xsl:value-of select="$escapedValue"/>"<xsl:if test="$isNotLast='true'"><xsl:text>,</xsl:text></xsl:if>
      </xsl:otherwise>
    </xsl:choose>   
  </xsl:template>
  
  <xsl:template name="escape-json">
    <xsl:param name="text" />
    <xsl:variable name="escape0">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$text" />
         <xsl:with-param name="symbolToEscape" >\</xsl:with-param>s
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape1">
       <xsl:call-template name="escape-string">
         <!-- <xsl:with-param name="text" select="$escape0" />
         <xsl:with-param name="symbolToEscape" >'</xsl:with-param>s  -->
         <xsl:with-param name="text" select="$escape0" />
         <xsl:with-param name="symbolToEscape" >'</xsl:with-param>s
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape2">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape1" />
         <xsl:with-param name="symbolToEscape">/</xsl:with-param>
      </xsl:call-template>
    </xsl:variable> 
    <xsl:variable name="escape3">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape2" />
         <xsl:with-param name="symbolToEscape" >[</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape4">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape3" />
         <xsl:with-param name="symbolToEscape" >]</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape5">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape4" />
         <xsl:with-param name="symbolToEscape" >{</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape6">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape5" />
         <xsl:with-param name="symbolToEscape" >}</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape7">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape6" />
         <xsl:with-param name="symbolToEscape" >\</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escape8">
       <xsl:call-template name="escape-string">
         <xsl:with-param name="text" select="$escape7" />
         <xsl:with-param name="symbolToEscape" >"</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$escape8" />
  </xsl:template>
  
  <xsl:template name="escape-string">
    <xsl:param name="text" />
    <xsl:param name="symbolToEscape" />
    <xsl:choose>
      <xsl:when test="contains($text, $symbolToEscape)">
        <xsl:value-of select="substring-before($text,$symbolToEscape)" />\<xsl:value-of select="$symbolToEscape" />
        <xsl:call-template name="escape-string">
          <xsl:with-param name="text" select="substring-after($text,$symbolToEscape)" />
          <xsl:with-param name="symbolToEscape" select="$symbolToEscape" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>