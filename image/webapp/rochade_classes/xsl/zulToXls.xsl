<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Stylesheet definition to transform zul to Excel file. 
	@author HG, 10.04.2012, created
	@de.rochade.copyright@ 
-->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="base.xsl"/>
	<xsl:output method="html" indent="yes" encoding="UTF-8" />
	<xsl:output media-type="application/vnd.ms-excel" />
	
	<xsl:template match="/">
		<html>
			<head>
				<title/>
			</head>
			<style type="text/css">
			</style>
			<body>
				<xsl:apply-templates select="*/*" />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="listbox">
		<table border="1" cellspacing="0" cellpadding="5">
			<thead>
				<xsl:for-each select="listhead/listheader">
					<th align="left" bgcolor="E8ECF0">
						<xsl:value-of select="@label" />
					</th>
				</xsl:for-each>
			</thead>
			<tbody>
				<xsl:choose>
					<xsl:when test="count(listitem) = 0">
						<tr>
							<td>
								<xsl:attribute name="colspan">
									<xsl:value-of select="count(listhead/listheader)"/>
								</xsl:attribute>
								...
							</td>
						</tr>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="listitem">
							<tr>
								<xsl:if test="position() mod 2 = 0">
									<xsl:attribute name="bgcolor">#F0F8FF</xsl:attribute>
								</xsl:if>
								<xsl:for-each select="listcell">
									<td>
										<xsl:choose>
											<!-- listcell with image always with 1 label only -->
											<xsl:when test="count(.//image)">
												<!-- 
												<fo:external-graphic>
													<xsl:attribute name="src">
														<xsl:value-of select=".//image/@src"/>
													</xsl:attribute>
												</fo:external-graphic>
												 --> 
												<xsl:value-of select=".//label/@value"/>
											</xsl:when>
											<!-- listcell without image only 1 label -->
											<xsl:when test="@label != ''">
												<xsl:value-of select="@label"/>
											</xsl:when>
											<!-- listcell with 1, 2 or more children (labels, a href)  -->
											<xsl:otherwise>
												<xsl:for-each select=".//label">
													<div>
														<xsl:value-of select="@value"/>
													</div>
												</xsl:for-each>
												<xsl:for-each select=".//a">
													<div>
														<xsl:value-of select="@label"/>
													</div>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:for-each>
							</tr>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</tbody>
			<xsl:if test="count(listfoot/listfooter)">
				<tfoot>
					<tr bgcolor="E8ECF0">
						<td>
							<xsl:attribute name="colspan">
								<xsl:value-of select="count(listhead/listheader)"/>
							</xsl:attribute>
							<xsl:value-of select="listfoot/listfooter/@label" />
						</td>
					</tr>
				</tfoot>
			</xsl:if>
		</table>
	</xsl:template>
	
	<xsl:template match="label">
		<xsl:choose>
			<xsl:when test="@sclass='asg-title-label'">
				<font size="4" xsl:use-attribute-sets="asg-title-label">
					<xsl:value-of select="@value" />
				</font>
			</xsl:when>
			<xsl:when test="@sclass='asg-itemname-label'">
				<font size="4" xsl:use-attribute-sets="asg-itemname-label">
					<xsl:value-of select="@value" />
				</font>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
