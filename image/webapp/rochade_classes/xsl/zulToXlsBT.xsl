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
				<table border="1" cellspacing="0" cellpadding="5">
					<thead>
					</thead>
					<tbody>
						<tr><td>

		<xsl:for-each select="//label[@sclass='asg-itemname-label']">
			<xsl:call-template name="ITEMNAME"></xsl:call-template>		
		</xsl:for-each>
		
		<xsl:for-each select="//label[@sclass='asg-itemtype-label']">
			<xsl:call-template name="ITEMTYPE"></xsl:call-template>		
		</xsl:for-each>

		<xsl:for-each select="//div[@id='hierarchicalPath']">
			<xsl:call-template name="CONTEXT"></xsl:call-template>		
		</xsl:for-each>

		<xsl:for-each select="//hbox[@id='hmodified']">
			<xsl:call-template name="MODIFIED"></xsl:call-template>		
		</xsl:for-each>

		<xsl:for-each select="//hbox[@id='howner']">
			<xsl:call-template name="OWNER"></xsl:call-template>		
		</xsl:for-each>

		<xsl:for-each select="//rows[@id='textGrid']">
				<xsl:call-template name="TXT"></xsl:call-template>
				<tr><td></td></tr>
		</xsl:for-each>

		<xsl:for-each select="//rows[@id='relGrid']/row">
				<xsl:call-template name="LNK"></xsl:call-template>
		</xsl:for-each>


						</td></tr>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
	
<!--
	<xsl:template name="ITEMTYPE">
		<tr><td>Name
		
		<xsl:value-of select="@value" />
		
		<xsl:for-each select="//label[@sclass='asg-itemname-label']">
			<xsl:call-template name="ITEMNAME"></xsl:call-template>
		</xsl:for-each>
		</td></tr>	
	</xsl:template>
-->
	
	<xsl:template name="ITEMNAME">
		<tr><td>Name</td><td>
			<xsl:value-of select="@value"/>	
		</td></tr>
	</xsl:template>
	
	<xsl:template name="ITEMTYPE">
		<tr><td>Item Type</td><td>
			<xsl:value-of select="@value"/>	
		</td></tr>
	</xsl:template>

	<xsl:template name="CONTEXT">		
		<tr><td>Glossary</td><td>
			<xsl:value-of select="div/label[1]/@value"/>
		</td></tr>
		<tr><td>Context</td><td>
			<xsl:value-of select="div/label[last()-1]/@value"/>
		</td></tr>
		<!--
		<tr><td>Business Term</td><td>
			<xsl:value-of select="div/label[3]/@value"/>
		</td></tr>
		-->
	</xsl:template>

	<xsl:template name="MODIFIED">		
		<tr><td> <xsl:value-of select="label/@value"/> </td>
		<td> <xsl:value-of select="div/label/@value"/> </td></tr>
	</xsl:template>

	<xsl:template name="OWNER">		
		<tr><td> <xsl:value-of select="label/@value"/> </td>
		<td> <xsl:value-of select="div/label/@value"/> </td></tr>
	</xsl:template>



	<xsl:template name="TXT">
		<xsl:for-each select="row">
			<xsl:choose>
				<xsl:when test="div/@id='DEFINITION'">
					<tr><td>Short Description</td>
					<xsl:if test="div/label/@sclass=''">
						<td>
						<xsl:value-of select="div/label/@value"/>
						</td>
					</xsl:if>
					</tr>
				</xsl:when>
				<xsl:when test="count(.//label) = 2">
					<tr>
					<xsl:for-each select=".//label">
					<xsl:if test="@sclass='asg-attribute-label-bold'">
						<td>
							<xsl:value-of select="@value"/>
						</td>
					</xsl:if>
					<xsl:if test="@sclass=''">
						<td>
							<xsl:value-of select="@value"/>
						</td>
					</xsl:if>
					</xsl:for-each>
					</tr>
				</xsl:when>
				<xsl:when  test="count(.//label) = 0">					
					<xsl:if test="count(.//html) = 1">
						<xsl:if test="div/html/content">
						<tr><td>Definition</td>
						<td>
						<html><content>

						<!-- <xsl:call-template name="wordwrap" /> -->
						<xsl:apply-templates />
						
						</content></html>
						</td></tr>
						</xsl:if>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="LNK">
		<xsl:for-each select=".//label">
			<xsl:if test="@sclass='asg-attribute-label-bold'">
			<xsl:choose>
				<xsl:when test="@value='Acronym:'">
				</xsl:when>
				<xsl:otherwise>
			<tr>
				<td>
				<b>
				<xsl:value-of select="@value"/>
				</b>
				</td>
				<td>			
				</td>
			</tr>
				</xsl:otherwise>
			</xsl:choose>
			</xsl:if>
		</xsl:for-each>
			<xsl:apply-templates />
	</xsl:template>


	<xsl:template match="listbox">
		<table border="1" cellspacing="0" cellpadding="5">
			<thead>
				<xsl:for-each select="listhead/listheader">
					<td align="left" >
						<b>
						<xsl:value-of select="@label" />
						</b>
					</td>
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
							</td>
						</tr>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="listitem">
							<tr>
								<xsl:if test="position() mod 2 = 0">
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
											<!-- listcell with 1, 2 or more labels -->
											<xsl:otherwise>
												<xsl:for-each select=".//label">
													<div>
														


			<xsl:choose>
				<xsl:when test="../../../../../../../@id='LbgACRONYM'">
								<tr>
								<td>Acronym:</td>
								<td><xsl:value-of select="@value"/></td>
								</tr>
								<tr>
								<td>
								</td>
								</tr>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@value"/>
				</xsl:otherwise>
			</xsl:choose>

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
					<tr>
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

	<!--
	<xsl:template name="wordwrap">
	 <xsl:param name="input" select="text()"/>
	 <xsl:choose>
	   <xsl:when test="contains($input, '&#xA;')">
	     <xsl:value-of select="substring-before($input, '&#xA;')"/>
	     <br />
	     <xsl:call-template name="wordwrap">
	       <xsl:with-param name="input" select="substring-after($input,'&#xA;')"/>
	     </xsl:call-template>
	   </xsl:when>
	   <xsl:otherwise>
	           <xsl:value-of select="$input"/>
	   </xsl:otherwise>
	 </xsl:choose>
	</xsl:template>
	-->

</xsl:stylesheet>