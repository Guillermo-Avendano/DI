<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Base attributes definition for other xls files 
	@author HG, 10.04.2012, created
	@de.rochade.copyright@ 
-->


<!-- Attention!!!!!!! 
	Do not define attribute set with font-style italic because then the Japanese glyphs cannot be displayed -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:attribute-set name="asg-title-label">
		<xsl:attribute name="font-size">16pt</xsl:attribute>
		<xsl:attribute name="color">#616161</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="asg-itemname-label">
		<xsl:attribute name="font-size">16pt</xsl:attribute>
		<xsl:attribute name="color">#15428b</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="asg-itemtype-label">
		<xsl:attribute name="font-size">14pt</xsl:attribute>
		<xsl:attribute name="color">#616161</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="tabLabel">
		<xsl:attribute name="font-size">14pt</xsl:attribute>
		<xsl:attribute name="color">#616161</xsl:attribute>
		<xsl:attribute name="border">thin black dashed</xsl:attribute>
		<xsl:attribute name="space-after">10pt</xsl:attribute>
		<xsl:attribute name="space-before">10pt</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="asg-groupbox-caption-label">
		<xsl:attribute name="font-size">14pt</xsl:attribute>
		<xsl:attribute name="color">#15428B</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="asg-attribute-label-bold">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="color">#15428B</xsl:attribute>
		<xsl:attribute name="space-before">12pt</xsl:attribute>
		<xsl:attribute name="space-after">12pt</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="asg-attribute-label-bold-italic">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="color">#15428B</xsl:attribute>
		<xsl:attribute name="space-before">12pt</xsl:attribute>
		<xsl:attribute name="space-after">12pt</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="objectinfo-label">
		<xsl:attribute name="font-size">9pt</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="objectinfo-value">
		<xsl:attribute name="font-size">9pt</xsl:attribute>
		<xsl:attribute name="color">#15428B</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="asg-label-unapproved-version">
		<xsl:attribute name="background-color">yellow</xsl:attribute>
		<xsl:attribute name="text-align">right</xsl:attribute>
	</xsl:attribute-set>
	
</xsl:stylesheet>
