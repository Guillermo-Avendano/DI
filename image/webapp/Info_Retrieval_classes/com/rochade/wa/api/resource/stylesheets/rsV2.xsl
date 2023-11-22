<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exslt="http://exslt.org/common"
	xmlns:dyn="http://exslt.org/dynamic"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="exslt dyn msxsl">
	<xsl:output method="xml" version="1.0"  indent="yes" /> <!-- encoding="UTF-8" -->
	
	<xsl:template match="/">
		<CategoryServiceResult>
			<xsl:attribute name="application"><xsl:value-of select="/t/Con/@con"/></xsl:attribute>
			<xsl:attribute name="metaGlossary"><xsl:value-of select="/t/Con/@glossaryApplServer"/></xsl:attribute>
			<xsl:attribute name="roBrowser"><xsl:value-of select="/t/Con/@roBrowser"/></xsl:attribute>
			<xsl:attribute name="roDatabase"><xsl:value-of select="/t/Con/@roDatabase"/></xsl:attribute>
			<xsl:attribute name="componentType"><xsl:value-of select="/t/Con/@componentType"/></xsl:attribute>
			<xsl:attribute name="_WorkLang"><xsl:value-of select="/t/Con/@_WorkLang"/></xsl:attribute>
			<xsl:attribute name="_ProjectionLang"><xsl:value-of select="/t/Con/@_ProjectionLang"/></xsl:attribute>
			<xsl:attribute name="def"><xsl:value-of select="/t/Con/@defaultLang"/></xsl:attribute>
			
			<xsl:apply-templates select="t"/>
		</CategoryServiceResult>
	</xsl:template>
	
	<xsl:template match="r">
		<row> 
			<xsl:apply-templates select="c"/>
			
			<CONTEXTPATH>
				<xsl:choose>
					<xsl:when test="/t/Con/@contextPath='short'">
						<xsl:value-of select="c[@attr='absPath']/t/r[position()=1]/c[@attr='name']/text()"/>
					</xsl:when>
					<xsl:otherwise>
					<xsl:apply-templates select="c[@attr='absPath']/t/r[position()=2]" mode="abspath_part">
						<xsl:with-param name="pos" select="2"/>
						<xsl:with-param name="count_r" select="count(c[@attr='absPath']/t/r)"/>  
						<xsl:with-param name="symbol"> &gt; </xsl:with-param>
						<xsl:with-param name="endPosition">1</xsl:with-param>
						<xsl:with-param name="start">true</xsl:with-param>
					  </xsl:apply-templates></xsl:otherwise>
				</xsl:choose>
				<!-- o switch: show context path, or show context only, or show context only with mouse over. -->
			</CONTEXTPATH>
		</row>
	</xsl:template>
	
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
		<!-- MyInfoAssist, when not connected to Solr (but directly to Rochade), does not read the 'c' elements but expects the following elements: 'name', 'DEFINITION', 'glossaryId', 'id, 'type' -->
		<!-- See the mapping in DefinitionLookup.xml about those expected field names: <IdField>id</IdField>, <NameField>name</NameField>, <TypeField>itemType</TypeField>, <DefinitionField>DEFINITION</DefinitionField>, <ScopeIDField>glossaryId</ScopeIDField>, <ContextPathField>CONTEXTPATH</ContextPathField> -->
		<!-- Moreover, when not connected to Solr (but directly to Rochade), MyInfoAssist is not able to display multi-language results. It displays only the result in the working language -->
		<xsl:if test="@attr='name' and not(@language)">
			<!-- build a 'name' node that contains the value for the working language (or the default language if working language not available) -->
			<!-- EDI-5873 if we want to really restore the same layout as 9.00 in 9.50, we should change this implementation to build a 'name' element
			that would be not the simple NAME attribute for the working language but that would be the concatenation of names for all the projection languages.
			However this could cause regression into GlobalSearch and into the Indexing Utility (see SVN history that explain why we have done changes here!).
			Moreover it would be emphasizing a misconception of MIA that displays results for multiple selected languages as a one line result where the name
			(but not the Definition) is tweaked to reflect the fact that the matching item has language-versions of its name attribute. A correct way to do,
			would be to display each language-version attributes of the matching item on a separate line. Then the user could select which language of the
			item he would to see (currently when clicking on the matching result, it is displayed automatically in the working language). -->
			<xsl:element name="name">
				<xsl:choose>
					<!-- if the language version of the name exists for the working language, use that value -->
					<xsl:when test="/t/Con/@_WorkLang!='' and contains(/t/Con/@_ProjectionLang, /t/Con/@_WorkLang) and parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@_WorkLang]"><!-- CAUTION: if workingLang is 'de', defaultLang is 'en' but requested projectionLang is only 'fr' we have to display the result in 'fr' because it it is the (only) specified language for the matching! -->
						<xsl:value-of select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@_WorkLang]/c[@attr='name']/text()"/>
						<xsl:text> [</xsl:text>
							<xsl:value-of select="/t/Con/@_WorkLang"/>
						<xsl:text>] </xsl:text>
					</xsl:when>
					<!-- else if the language version of the name exists for the default language, use that value -->
					<xsl:when test="/t/Con/@defaultLang!='' and contains(/t/Con/@_ProjectionLang, /t/Con/@defaultLang) and parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@defaultLang]"><!-- CAUTION: if workingLang is 'de', defaultLang is 'en' but requested projectionLang is only 'fr' we have to display the result in 'fr' because it it is the (only) specified language for the matching! -->
						<xsl:value-of select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@defaultLang]/c[@attr='name']/text()"/>
						<xsl:text> [</xsl:text>
							<xsl:value-of select="/t/Con/@defaultLang"/>
						<xsl:text>] </xsl:text>
					</xsl:when>
					<!-- CAUTION: if workingLang is 'de', defaultLang is 'en' but requested projectionLang is only 'fr' we have to display the result in 'fr' because it it is the (only) specified language for the matching! -->
					<xsl:when test="/t/Con/@_ProjectionLang!='' and not(contains(/t/Con/@_ProjectionLang, ',')) and parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@_ProjectionLang]">
						<xsl:value-of select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@_ProjectionLang]/c[@attr='name']/text()"/>
						<xsl:text> [</xsl:text>
							<xsl:value-of select="/t/Con/@_ProjectionLang"/>
						<xsl:text>] </xsl:text>
					</xsl:when>
					<!-- else use direclty the value of the name node without language -->
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<!-- Other solution: build a 'name' node that contains in once all the language version of the names, each separated by a return-to-line -->
			<!--
			<xsl:element name="name">
				<xsl:variable name="ProjLangsFragment">
					<xsl:call-template name="splitLangsWithOrder">
						<xsl:with-param name="text" select="/t/Con/@_ProjectionLang" />
						<xsl:with-param name="separator" select="','" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="function-available('msxsl:node-set')">
						<xsl:call-template name="buildLangNames">
							<xsl:with-param name="langs" select="msxsl:node-set($ProjLangsFragment)/*" />
							<xsl:with-param name="targetNode" select="parent::r" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="buildLangNames">
							<xsl:with-param name="langs" select="exslt:node-set($ProjLangsFragment)/*" />
							<xsl:with-param name="targetNode" select="parent::r" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			-->
			
			<!-- While a 'name' element is expected by MyInfoAssist, for conformity to classical naming rules, also create a 'NAME' element with direct content (no [language] suffix). -->
			<xsl:element name="NAME">
				<xsl:value-of select="."/>
			</xsl:element>
			
			<!-- DEPRECATED code producing ugly display
			<xsl:element name="name">
				<xsl:value-of select="."/>
				<xsl:if test="/t/Con/@_WorkLang!=''">
					<xsl:text> [</xsl:text>
						<xsl:value-of select="/t/Con/@_WorkLang"/>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()=/t/Con/@defaultLang and c[@attr='language']/text()!=/t/Con/@_WorkLang]">
					<xsl:value-of select="c[@attr='name']"/>
					<xsl:text> [</xsl:text>
					<xsl:value-of select="c[@attr='language']"/>
					<xsl:text>] </xsl:text>
				</xsl:for-each>
				<xsl:for-each select="parent::*/c[@attr='languages']/t/r[c[@attr='name']!='' and c[@attr='language']/text()!=/t/Con/@defaultLang and c[@attr='language']/text()!=/t/Con/@_WorkLang and c[@attr='language']/text()!=/t/Con/@_WorkLang and contains(/t/Con/@_ProjectionLang, c[@attr='language']/text())]">
					<xsl:value-of select="c[@attr='name']"/>
					<xsl:text> [</xsl:text>
					<xsl:value-of select="c[@attr='language']"/>
					<xsl:text>] </xsl:text>
				</xsl:for-each>
			</xsl:element>
			-->
		</xsl:if>
		
		<xsl:if test="@attr='languages'">
			<xsl:for-each select="t/r">
				<!-- MyInfoAssist, when not connected to Solr (but directly to Rochade), does not read the 'c' elements but expects the following elements: 'name', 'DEFINITION', 'glossaryId', 'id, 'type' -->
				<!-- See the mapping in DefinitionLookup.xml about those expected field names: <IdField>id</IdField>, <NameField>name</NameField>, <TypeField>itemType</TypeField>, <DefinitionField>DEFINITION</DefinitionField>, <ScopeIDField>glossaryId</ScopeIDField>, <ContextPathField>CONTEXTPATH</ContextPathField> -->
				<!-- Here produce the nodes like 'NAMEen', 'NAMEde'... -->
				<xsl:variable name="langName">
					<xsl:text>NAME</xsl:text>
					<xsl:value-of select="c[@attr='language']"/>
				</xsl:variable>
				<xsl:element name="{$langName}">
					<xsl:value-of select="c[@attr='name']"/>
				</xsl:element>
				
				<!-- EDI-1529: additionally create new elements for name entries using the common pattern used elsewhere '<c attr="name" language="fr">GlosDef-fr</c>' so it is easier to parse and less error prone -->
				<xsl:element name="c">
					<xsl:attribute name="attr">name</xsl:attribute>
					<xsl:attribute name="language">
						<xsl:value-of select="c[@attr='language']"/>
					</xsl:attribute>
					<xsl:value-of select="c[@attr='name']"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="@attr='glossaryId'">
			<xsl:element name="glossaryId">
				<xsl:value-of select="text()"/>
			</xsl:element>
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
		
		<!-- MyInfoAssist, when not connected to Solr (but directly to Rochade), does not read the 'c' elements but expects the following elements: 'name', 'DEFINITION', 'glossaryId', 'id, 'type' -->
		<!-- See the mapping in DefinitionLookup.xml about those expected field names: <IdField>id</IdField>, <NameField>name</NameField>, <TypeField>itemType</TypeField>, <DefinitionField>DEFINITION</DefinitionField>, <ScopeIDField>glossaryId</ScopeIDField>, <ContextPathField>CONTEXTPATH</ContextPathField> -->
		<!-- Moreover, when not connected to Solr (but directly to Rochade), MyInfoAssist is not able to display multi-language results. It displays only the result in the working language -->
		<xsl:if test="@attr='DEFINITION'">
			<xsl:choose>
				<xsl:when test="not(@language)">
					<!-- build a 'DEFINITION' node that contains the value for the working language (or the default language if working language not available) -->
					<xsl:element name="DEFINITION">
						<xsl:choose>
							<!-- if the language version of the name exists for the working language, use that value -->
							<xsl:when test="/t/Con/@_WorkLang!='' and contains(/t/Con/@_ProjectionLang, /t/Con/@_WorkLang) and parent::*/c[@attr='DEFINITION' and @language=/t/Con/@_WorkLang]/text()!=''"><!-- CAUTION: if workingLang is 'de', defaultLang is 'en' but requested projectionLang is only 'fr' we have to display the result in 'fr' because it it is the (only) specified language for the matching! --> 
								<xsl:text>[</xsl:text>
									<xsl:value-of select="/t/Con/@_WorkLang"/>
								<xsl:text>] </xsl:text>
								<xsl:value-of select="parent::*/c[@attr='DEFINITION' and @language=/t/Con/@_WorkLang]/text()"/>
							</xsl:when>
							<!-- else if the language version of the name exists for the default language, use that value -->
							<xsl:when test="/t/Con/@defaultLang!='' and contains(/t/Con/@_ProjectionLang, /t/Con/@defaultLang) and parent::*/c[@attr='DEFINITION' and @language=/t/Con/@defaultLang]/text()!=''"><!-- CAUTION: if workingLang is 'de', defaultLang is 'en' but requested projectionLang is only 'fr' we have to display the result in 'fr' because it it is the (only) specified language for the matching! -->
								<xsl:text>[</xsl:text>
									<xsl:value-of select="/t/Con/@defaultLang"/>
								<xsl:text>] </xsl:text>
								<xsl:value-of select="parent::*/c[@attr='DEFINITION' and @language=/t/Con/@defaultLang]/text()"/>
							</xsl:when>
							<!-- CAUTION: if workingLang is 'de', defaultLang is 'en' but requested projectionLang is only 'fr' we have to display the result in 'fr' because it it is the (only) specified language for the matching! -->
							<xsl:when test="/t/Con/@_ProjectionLang!='' and not(contains(/t/Con/@_ProjectionLang, ',')) and parent::*/c[@attr='DEFINITION' and @language=/t/Con/@_ProjectionLang]/text()!=''">
								<xsl:text>[</xsl:text>
									<xsl:value-of select="/t/Con/@_ProjectionLang"/>
								<xsl:text>] </xsl:text>
								<xsl:value-of select="parent::*/c[@attr='DEFINITION' and @language=/t/Con/@_ProjectionLang]/text()"/>
							</xsl:when>
							<!-- else use direclty the value of the name node without language -->
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					
					<!-- Other solution: build a 'DEFINITION' node that contains in once all the language version of the definitions, each separated by a return-to-line -->
					<!--
					<xsl:element name="DEFINITION">
						<xsl:variable name="ProjLangsFragment">
							<xsl:call-template name="splitLangsWithOrder">
								<xsl:with-param name="text" select="/t/Con/@_ProjectionLang" />
								<xsl:with-param name="separator" select="','" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="function-available('msxsl:node-set')">
								<xsl:call-template name="buildLangDefinitions">
									<xsl:with-param name="langs" select="msxsl:node-set($ProjLangsFragment)/*" />
									<xsl:with-param name="targetNode" select="parent::r" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="buildLangDefinitions">
									<xsl:with-param name="langs" select="exslt:node-set($ProjLangsFragment)/*" />
									<xsl:with-param name="targetNode" select="parent::r" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					-->
				</xsl:when>
				<xsl:otherwise>
					<!-- create elements DEFINITION, DEFINITIONen, DEFINITIONde... according to the current c element that we are processing -->
					<xsl:variable name="langName">
						<xsl:text>DEFINITION</xsl:text>
						<xsl:value-of select="@language"/>
					</xsl:variable>
					<xsl:element name="{$langName}">
						<xsl:value-of select="text()"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<!-- Todo: decide from outside -->
		<xsl:if test="@attr!='absPath' and @attr!='languages'"> 
			<xsl:copy>
				<xsl:apply-templates select="@*|node()|text()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="r" mode="abspath_part">
		<xsl:param name="pos"/>
		<xsl:param name="count_r"/>
		<xsl:param name="symbol"/>
		<xsl:param name="endPosition"/>
		<xsl:param name="start"/>
		
		<xsl:if test="$pos != $count_r">
			<xsl:choose>
				<xsl:when test="$pos != $count_r - 1">
					<xsl:text>.</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$start!='true'">
						<xsl:value-of select="$symbol"/>
					</xsl:if>
					<xsl:value-of select="c[position()=3]/text()"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$pos + $endPosition &lt; $count_r">
				<xsl:apply-templates select="parent::*/r[position()=$pos + 1]" mode="abspath_part">
					<xsl:with-param name="pos" select="$pos + 1"/>
					<xsl:with-param name="count_r" select="$count_r"/>
					<xsl:with-param name="symbol" select="$symbol"/>
					<xsl:with-param name="endPosition">1</xsl:with-param>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="t">
		<xsl:apply-templates select="r"/>
	</xsl:template>
	
	<xsl:template match="@*|node()|text()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|text()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="splitLangsWithOrder">
		<xsl:param name="text" select="."/>
		<xsl:param name="separator" select="','"/>
		
		<xsl:if test="string-length($text)>0">
			<xsl:variable name="lang">
				<xsl:value-of select="substring-before(concat($text, $separator), $separator)"/>
			</xsl:variable>
			<item>
				<xsl:value-of select="$lang"/>
				<order>
					<xsl:choose>
						<xsl:when test="$lang=/t/Con/@_WorkLang">
							<xsl:text>0</xsl:text>
						</xsl:when>
						<xsl:when test="$lang=/t/Con/@defaultLang">
							<xsl:text>1</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>9</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</order>
			</item>
			
			<xsl:call-template name="splitLangsWithOrder">
				<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				<xsl:with-param name="separator" select="$separator"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="buildLangNames">
		<xsl:param name="langs" />
		<xsl:param name="targetNode" />
		<xsl:param name="separator"><xsl:text>&#10;</xsl:text></xsl:param>
		
		<!-- Convert parameter to a variable and convert it again to a node-set because, with Java's XSL transformer, the parameter will be text only once entered into the for-each (Saxon has not such an issue). -->
		<xsl:variable name="containerNode" select="exslt:node-set($targetNode)" />
		
		<xsl:for-each select="$langs">
			<!-- Java's XSL transformer is not able to process correctly the xsl:sort so at end the for-each loop is totally skipped (Saxon has not such an issue)
			<xsl:sort select="./order" data-type="number" />
			-->
			
			<xsl:variable name="lang">
				<xsl:value-of select="./child::text()" />
			</xsl:variable>
			
			<xsl:value-of select="$containerNode/c[@attr='languages']/t/r[c[@attr='language']/text()=$lang]/c[@attr='name']/text()" />
			<xsl:text> [</xsl:text>
				<xsl:value-of select="$lang"/>
			<xsl:text>] </xsl:text>
			
			<xsl:if test="count($langs)>0">
				<xsl:value-of select="$separator" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="buildLangDefinitions">
		<xsl:param name="langs" />
		<xsl:param name="targetNode" />
		<xsl:param name="separator"><xsl:text>&#10;</xsl:text></xsl:param>
		
		<!-- Convert parameter to a variable and convert it again to a node-set because, with Java's XSL transformer, the parameter will be text only once entered into the for-each (Saxon has not such an issue). -->
		<xsl:variable name="containerNode" select="exslt:node-set($targetNode)" />
		
		<xsl:for-each select="$langs">
			<!-- Java's XSL transformer is not able to process correctly the xsl:sort so at end the for-each loop is totally skipped (Saxon has not such an issue)
			<xsl:sort select="./order" data-type="number" />
			-->
			
			<xsl:variable name="lang">
				<xsl:value-of select="./child::text()" />
			</xsl:variable>
			
			<xsl:text>[</xsl:text>
				<xsl:value-of select="$lang"/>
			<xsl:text>] </xsl:text>
			<xsl:value-of select="$containerNode/c[@attr='DEFINITION' and @language=$lang]/text()" />
			
			<xsl:if test="count($langs)>0">
				<xsl:value-of select="$separator" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>