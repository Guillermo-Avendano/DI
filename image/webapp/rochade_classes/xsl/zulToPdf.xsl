<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Stylesheet definition to transform zul to PDF file. 
	@author HG, 10.04.2012, created
	@de.rochade.copyright@ 
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<xsl:include href="base.xsl"/>
	<xsl:include href="htmlToPdf.xsl"/>
	<xsl:output method="xml" version="1.0" indent="yes" />
	<xsl:strip-space elements="tabpanels" />

	<xsl:template match="/">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Arial,'MS Gothic',sans-serif">
			<fo:layout-master-set>
				<fo:simple-page-master master-name="table"
					page-height="11in" page-width="8.5in" margin-top="50pt"
					margin-bottom="50pt" margin-left="72pt" margin-right="72pt">
					<fo:region-body margin-top="50pt" margin-bottom="50pt" />
					<fo:region-before region-name="before" extent="50pt" />
					<fo:region-after region-name="after" extent="50pt" />
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="table">
				<fo:static-content flow-name="before">
					<fo:table width="100%" table-layout="fixed">
						<fo:table-column column-width="468pt" />
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<fo:block font-size="10pt" text-align="center"><xsl:value-of select="*/@title" />
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
					<fo:block>
						<fo:leader leader-pattern="rule" rule-style="solid"
							leader-length="100%" />
					</fo:block>
				</fo:static-content>
				<fo:static-content flow-name="after">
					<fo:block>
						<fo:leader leader-pattern="rule" rule-style="solid"
							leader-length="100%" />
					</fo:block>
					<fo:table width="100%" table-layout="fixed">
						<fo:table-column column-width="468pt" />
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<fo:block font-size="10pt" text-align="center">
										Page
										<fo:page-number />
										of
										<fo:page-number-citation ref-id="TheVeryLastPage" />
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:apply-templates select="*/*" />
					<fo:block id="TheVeryLastPage" font-size="0pt"
						line-height="0pt" space-after="0pt" />
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>

    <!-- with page divheader break -->
	<xsl:template match="*/div[@id='divheader']">
		<fo:block padding-after="9pt" break-before="page">
			<xsl:for-each select=".//label">
				<xsl:choose>
					<xsl:when test="../../@id='hierarchicalPath'">
						<fo:wrapper xsl:use-attribute-sets="objectinfo-value">
							<xsl:value-of select="@value" /> 
							<xsl:if test="@sclass = 'asg-path-label asg-path-element'">
								=>
							</xsl:if> 
						</fo:wrapper>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." />
						<xsl:text>&#160;&#160;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>	
			</xsl:for-each>
		</fo:block>
	</xsl:template>

	<xsl:template match="*/div[@id='headerTitle']">
		<fo:block padding-after="9pt">
			<xsl:for-each select=".//label">
				<xsl:apply-templates select="." />
				<xsl:text>&#160;&#160;</xsl:text>
			</xsl:for-each>
		</fo:block>
	</xsl:template>

	<xsl:template match="*/div[@id='divobjinfo']">
		<xsl:if test=".//div[@id='hbinfo']">
			<fo:table width="80%" table-layout="fixed" border-style="solid">
				<fo:table-column number-columns-repeated="2" column-width="50%" />
				<fo:table-body>
					<xsl:for-each select=".//hbox">
						<fo:table-row>
							<xsl:for-each select=".//label">
								<fo:table-cell padding="1pt" border-style="solid">
									<xsl:choose>
										<xsl:when test="name(..) = 'div'">
											<fo:block xsl:use-attribute-sets="objectinfo-value">
												<xsl:value-of select="@value" />
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block xsl:use-attribute-sets="objectinfo-label">
												<xsl:value-of select="@value" />
											</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
							</xsl:for-each>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tabpanel">
		<xsl:if test="@label != ''">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<fo:block xsl:use-attribute-sets="tabLabel" space-before="15pt">
						Tab
						<xsl:value-of select="position()" />
						-
						<xsl:value-of select="@label" />
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block xsl:use-attribute-sets="tabLabel" break-before="page">
						Tab
						<xsl:value-of select="position()" />
						-
						<xsl:value-of select="@label" />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:apply-templates select="*/*" />
	</xsl:template>
	
	<xsl:template match="groupbox">
		<fo:block border="thin black dashed" padding="5pt" space-before="20pt" space-after="20pt">
			<xsl:apply-templates select="*/*" />
		</fo:block>
	</xsl:template>	
	
	<!-- <xsl:template match="radiogroup">
		<fo:block>
			<xsl:value-of select="@label" />
		</fo:block>
	</xsl:template> -->
	
	<xsl:template match="combobox">
		<fo:wrapper>
			<xsl:value-of select="@value" />
		</fo:wrapper>
	</xsl:template>
	
	<xsl:template match="label">
		<xsl:if test="@value != ''">
			<xsl:choose>
				<xsl:when test="@sclass='asg-title-label'">
					<fo:wrapper xsl:use-attribute-sets="asg-title-label">
						<xsl:value-of select="@value" />
					</fo:wrapper>
				</xsl:when>
				<xsl:when test="@sclass='asg-itemname-label'">
					<fo:wrapper xsl:use-attribute-sets="asg-itemname-label">
						<xsl:value-of select="@value" />
					</fo:wrapper>
				</xsl:when>
				<xsl:when test="@sclass='asg-itemtype-label'">
					<fo:wrapper xsl:use-attribute-sets="asg-itemtype-label">
						<xsl:value-of select="@value" />
					</fo:wrapper>
					<fo:block space-before="10pt"/>
				</xsl:when>
				<xsl:when test="@sclass='asg-groupbox-caption-label'">
					<fo:block xsl:use-attribute-sets="asg-groupbox-caption-label">
						<xsl:value-of select="@value" />
					</fo:block>
				</xsl:when>
				<xsl:when test="@sclass='asg-attribute-label-bold'">
					<fo:block xsl:use-attribute-sets="asg-attribute-label-bold">
						<xsl:value-of select="@value" />
					</fo:block>
				</xsl:when>
				<xsl:when test="@sclass='asg-attribute-label-bold-italic'">
					<fo:block xsl:use-attribute-sets="asg-attribute-label-bold-italic">
						<xsl:value-of select="@value" />
					</fo:block>
				</xsl:when>
				<xsl:when test="@sclass='asg-label-unapproved-version'">
					<!--  fo:block-container width="50%" -->
						<fo:block xsl:use-attribute-sets="asg-label-unapproved-version" >
							<xsl:value-of select="@value" />
						</fo:block>
					<!--  / fo : block - container -->
				</xsl:when>
				<xsl:when test="@sclass='asg-bpk-lineage-comparison-level-label'">
					<fo:wrapper>
						<xsl:value-of select="@value" />
					</fo:wrapper>
				</xsl:when>
				<xsl:otherwise>
					<fo:block linefeed-treatment="preserve">
						<xsl:value-of select="@value" />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*/div[@id='itemDiagram']">
		<xsl:for-each select=".//image[1]">
			<xsl:if test="@src != ''">
				<fo:block>
					<fo:external-graphic>
						<xsl:attribute name="src">
							<xsl:value-of select="@src"/>
						</xsl:attribute>
					</fo:external-graphic>
				</fo:block> 
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	 
	<xsl:template match="listbox">
		<fo:table width="100%" table-layout="fixed" border-style="solid"
			font-size="8pt" space-before="2pt" table-omit-footer-at-break="true">
			<xsl:if test="count(listhead/listheader) + count(auxhead/auxheader)">
				<fo:table-header>
					<xsl:if test="count(auxhead/auxheader)">
						<fo:table-row background-color="#E8ECF0">
							<xsl:for-each select="auxhead/auxheader">
								<fo:table-cell padding="1pt" border-bottom-style="none" 
									border-right-style="solid" >
									<xsl:attribute name="number-columns-spanned">
										<xsl:value-of select="@colspan" />
									</xsl:attribute>
									<fo:block font-weight="bold">
										<xsl:value-of select="@label" />
									</fo:block>
								</fo:table-cell>
							</xsl:for-each>
						</fo:table-row>
					</xsl:if>
					<fo:table-row>

						<xsl:for-each select="listhead/listheader">
							<fo:table-cell padding="1pt" border-bottom-style="solid"
								border-right-style="solid" >
								<xsl:if test="@color != ''">
									<xsl:attribute name="color">
										<xsl:value-of select="@color"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@background-color != ''">
									<xsl:attribute name="background-color">
										<xsl:value-of select="@background-color"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@font-family != ''">
									<xsl:attribute name="font-family">
										<xsl:value-of select="@font-family"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@font-size != ''">
									<xsl:attribute name="font-size">
										<xsl:value-of select="@font-size"/>
									</xsl:attribute>
								</xsl:if>
								<fo:block font-weight="bold">
									<xsl:value-of select="@label" />
								</fo:block>
							</fo:table-cell>
						</xsl:for-each>
					</fo:table-row>
				</fo:table-header>
			</xsl:if>
			<xsl:if test="count(listfoot/listfooter)">
				<fo:table-footer>
					<fo:table-row background-color="#E8ECF0">
						<fo:table-cell>
							<xsl:attribute name="number-columns-spanned">
								<xsl:value-of select="count(listhead/listheader)"/>
							</xsl:attribute>
							<fo:block>
								<xsl:value-of select="listfoot/listfooter/@label" />
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-footer>
			</xsl:if>
			<fo:table-body>
				<xsl:choose>
					<xsl:when test="count(listitem) = 0">
						<fo:table-row>
							<fo:table-cell>
								<xsl:attribute name="number-columns-spanned">
									<xsl:value-of select="count(listhead/listheader)"/>
								</xsl:attribute>
								<fo:block text-align="center">...</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="listitem">
							<fo:table-row>
								<xsl:if test="@color != ''">
									<xsl:attribute name="color">
										<xsl:value-of select="@color"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@background-color != ''">
									<xsl:attribute name="background-color">
										<xsl:value-of select="@background-color"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@font-family != ''">
									<xsl:attribute name="font-family">
										<xsl:value-of select="@font-family"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="@font-size != ''">
									<xsl:attribute name="font-size">
										<xsl:value-of select="@font-size"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:for-each select="listcell">
									<fo:table-cell padding="1pt"
										border-bottom-style="solid" border-right-style="solid">
										<fo:block>
											<xsl:choose>
												<!-- listcell with child image and 1 label only -->
												<xsl:when test="count(.//image)">
													<fo:block>
														<fo:external-graphic>
															<xsl:attribute name="src">
																<xsl:value-of select=".//image/@src"/>
															</xsl:attribute>
														</fo:external-graphic> 
														<xsl:value-of select=".//label/@value"/>
													</fo:block>
												</xsl:when>
												<!-- listcell with attr image, with/without label -->
												<xsl:when test="@image != ''">
													<fo:block>
														<fo:external-graphic>
															<xsl:attribute name="src">
																<xsl:value-of select="@image"/>
															</xsl:attribute>
														</fo:external-graphic>
														<xsl:value-of select="@label"/> <!-- normally from attr label -->
														<xsl:value-of select=".//label/@value"/> <!-- could be also from comp label -->
													</fo:block>
												</xsl:when>
												<!-- listcell without image only 1 label -->
												<xsl:when test="@label != ''">
													<fo:block>
														<xsl:value-of select="@label"/>
													</fo:block>
												</xsl:when>
												<!-- listcell with 1, 2 or more children (labels, a href, nested listcell) -->
												<xsl:otherwise>
													<xsl:for-each select=".//label">
														<fo:block>
															<xsl:value-of select="@value"/>
														</fo:block>
													</xsl:for-each>
													<xsl:for-each select=".//a">
														<fo:block>
															<xsl:value-of select="@label"/>
														</fo:block>
													</xsl:for-each>
													<xsl:for-each select=".//listcell">
														<fo:block>
															<xsl:value-of select="@label"/>
														</fo:block>
													</xsl:for-each>
												</xsl:otherwise>
											</xsl:choose>
										</fo:block>
									</fo:table-cell>
								</xsl:for-each>
							</fo:table-row>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
</xsl:stylesheet>
