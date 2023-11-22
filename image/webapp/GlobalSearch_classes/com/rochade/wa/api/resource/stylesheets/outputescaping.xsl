<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" version="4.0" indent="yes" /> <!-- encoding="UTF-8" -->

  <xsl:template match="/">
    <a><xsl:value-of select="//c/text()" disable-output-escaping="yes"/></a>
  </xsl:template>
  
</xsl:stylesheet>