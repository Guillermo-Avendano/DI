<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--xsl:strip-space elements="description" /-->

  <xsl:output method="xml" />

  <xsl:template match="/">
    <t>
      <h t="User Defined" u="">
        <d n="id" t="long" />
        <d n="DefId" t="String" />
        <d n="DefParentId" t="String" />
        <d n="DefName" t="String" />
        <d n="Label" t="String" />
        <d n="type" t="String" />
        <d n="InputType" t="String" />
        <d n="Option" t="String" />
        <d n="ParamValue" t="String" />
      </h>
      <xsl:apply-templates select="//categories/category"/>
      <xsl:apply-templates select="//category/child::*[not (name()='context') or not (name()='category')]"/>
      <xsl:apply-templates select="//category/child::*[not (name()='context') or not (name()='category')]" mode="param"/>
      </t>
  </xsl:template>

  <xsl:template match="category">
    <xsl:param name="parent"></xsl:param>
    <r>
      <c n="" />
      <c><xsl:value-of select="@id"/></c>
      <c><xsl:value-of select="$parent"/></c>
      <c><xsl:value-of select="@name"/></c>
      <c><xsl:value-of select="@label"/></c>
      <c>Category</c>
    </r>
    <xsl:apply-templates select="category">
      <xsl:with-param name="parent"><xsl:value-of select="@id"/></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="node()">
    <r>
      <c n="" />
      <c><xsl:value-of select="parent::*/@name"/>.<xsl:value-of select="@id"/></c>
      <c><xsl:value-of select="parent::*/@name"/></c>
      <c><xsl:value-of select="@name"/></c>
      <c><xsl:value-of select="@label"/></c>
      <c>Property</c>
    </r>
  </xsl:template>

  <xsl:template match="node()" mode="param">
    <xsl:variable name="p"><xsl:value-of select="parent::*/@id"/>.<xsl:value-of select="name()"/></xsl:variable>
    <xsl:variable name="pname"><xsl:value-of select="name()"/></xsl:variable>
    <xsl:apply-templates select="@*" mode="param">
      <xsl:with-param name="parent" select="$p"/>
      <xsl:with-param name="pname" select="name()"/>
    </xsl:apply-templates>                       
  </xsl:template>

  <xsl:template match="@*" mode="param">
    <xsl:param name="parent"/>
    <xsl:param name="pname"/>
    <!--xsl:param name="patternref"/-->
    <xsl:variable name="x" select="."/>
    <xsl:choose>
      <xsl:when test="contains($x,'{$')">
        <r>
          <c n="" />
          <c><xsl:value-of select="$parent"/>.<xsl:value-of select="name()"/></c>
          <c><xsl:value-of select="name()"/></c>
          <c><xsl:value-of select="//pattern/descendant::rule[contains(@forall,$pname)]/param/@name"/></c>
          <c><xsl:value-of select="//pattern/descendant::rule[contains(@forall,$pname)]/param/@label"/></c>
          <c>PARAM</c>
          <c n="" />
          <c n="" />
          <c><xsl:value-of select="."/></c>
        </r>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="contains(//pattern/descendant::rule[contains(@forall,$pname)]/descendant-or-self::param/@value,'//option')">
          <xsl:if test="//option[@id=$x]">
            <r>
              <c n="" />
              <c><xsl:value-of select="$parent"/>.<xsl:value-of select="name()"/></c>
              <c><xsl:value-of select="name()"/></c>
              <c><xsl:value-of select="//option[@id=$x]/@name"/></c>
              <c><xsl:value-of select="//option[@id=$x]/@label"/></c>
              <c>Option</c>
              <c><xsl:value-of select="//option[@id=$x]/@inputtype"/></c>
              <c n="" />
              <c><xsl:value-of select="."/></c>
            </r>
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  <!--
      <xsl_comment>
        <xsl_value-of select="$vd"/>
      </xsl_comment>
      <xsl_for-each select="//valDom[@id=$vd]">
        <xsl_apply-templates select="node()|@*"/>
      </xsl_for-each>
   
-->
 

</xsl:stylesheet>