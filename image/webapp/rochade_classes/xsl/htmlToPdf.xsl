<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Stylesheet definition to transform html to PDF file. 
	@author HG, 10.04.2012, created
	@de.rochade.copyright@ 
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<xsl:output method="xml" version="1.0" indent="yes" />
	
	<xsl:template match="html">
		<xsl:apply-templates select="content" />
	</xsl:template>

	<!-- The HTML <content> contains all of FCK elements from Editor. -->
	<xsl:template match="content">
		<fo:block font-size="12pt" line-height="15pt" space-after="12pt">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- Processing for the anchor tag is complex. 
		First of all, if this is a named anchor, we write an empty 
		<fo:block> with the appropriate id. (In the special case that the next element 
		is an <h1>, we ignore the element altogether and put the id on the <h1>.) 
		Next, if this is a regular anchor and the href starts with a hash mark (#), 
		we create a link with an internal-destination. Otherwise, we create a link 
		with an external destination. -->
	<xsl:template match="a">
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:if test="not(name(following-sibling::*[1]) = 'h1')">
					<fo:block line-height="0pt" space-after="0pt" font-size="0pt"
						id="{@name}" />
				</xsl:if>
			</xsl:when>
			<xsl:when test="@href">
				<fo:basic-link color="blue" text-decoration="underline">
					<xsl:choose>
						<xsl:when test="starts-with(@href, '#')">
							<xsl:attribute name="internal-destination">
				            	<xsl:value-of select="substring(@href, 2)" />
				            </xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="external-destination">
				                <xsl:value-of select="@href" />
				            </xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="*|text()" />
				</fo:basic-link>
				<xsl:if test="starts-with(@href, '#')">
					<xsl:text> on page </xsl:text>
					<fo:page-number-citation ref-id="{substring(@href, 2)}" />
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- We render an address element in italics.  -->
	<xsl:template match="address">
		<fo:block font-style="italic" space-after="12pt">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- For bold elements, we just change the font-weight. -->
	<xsl:template match="b">
		<fo:inline font-weight="bold">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- The big element is handled 
		with a relative font size. That means a <big> element inside another <big> 
		element will be even bigger, just as it is in HTML. -->
	<xsl:template match="big">
		<fo:inline font-size="120%">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- A blockquote is indented on both sides. -->
	<xsl:template match="blockquote">
		<fo:block start-indent="1.5cm" end-indent="1.5cm"
			space-after="12pt">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- We handle a break element by inserting an empty <fo:block>. -->
	<xsl:template match="br">
		<fo:block>
		</fo:block>
	</xsl:template>

	<!-- The <cite> element is rendered in italics, unless it's inside an 
		italic (<i>) element. We use the parent axis to check this. -->
	<xsl:template match="cite">
		<xsl:choose>
			<xsl:when test="parent::i">
				<fo:inline font-style="normal">
					<xsl:apply-templates select="*|text()" />
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-style="italic">
					<xsl:apply-templates select="*|text()" />
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- We render <code> inline in a monospaced font. -->
	<xsl:template match="code">
		<fo:inline font-family="monospace">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- We don't do anything with the <dl> element, we just handle the elements 
		it contains. Notice that we're ignoring any text that appears in the <dl> itself; 
		I'm not sure if that's the right call. -->
	<xsl:template match="dl">
		<xsl:apply-templates select="*" />
	</xsl:template>

	<!-- A definition term is rendered in bold. We specify keep-with-next here, 
		although it doesn't always work	with FOP. -->
	<xsl:template match="dt">
		<fo:block font-weight="bold" space-after="2pt"
			keep-with-next="always">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- We handle each <dd> element 
		as an indented block beneath the defined term. If the following element is 
		another <dd>, that means it's another definition for the same term. In that 
		case, we don't put as much vertical space after the block. -->
	<xsl:template match="dd">
		<fo:block start-indent="1cm">
			<xsl:attribute name="space-after">
		        <xsl:choose>
		          <xsl:when test="name(following::*[1]) = 'dd'">
		            <xsl:text>3pt</xsl:text>
		          </xsl:when>
		          <xsl:otherwise>
		            <xsl:text>12pt</xsl:text>
		          </xsl:otherwise>
		        </xsl:choose>
		    </xsl:attribute>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- The HTML <em> element is typically rendered in italics. -->
	<xsl:template match="em">
		<fo:inline font-style="italic">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- Element <span> and all <h*> can have style (color, size and font-family). -->
	<xsl:template name="checkStyle">
		<xsl:param name="style" />
			<!-- check style only if it has non empty value -->
			<xsl:if test="string-length($style) > 0">
				<xsl:if test="starts-with($style, 'background-color')">
					<xsl:variable name="background-color">
						<xsl:value-of select="translate(substring-after($style, 'background-color:'), ';', '')"/>
					</xsl:variable>
					<xsl:attribute name="background-color"><xsl:value-of select="$background-color"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="starts-with($style, 'color')">
					<xsl:variable name="color">
						<xsl:value-of select="translate(substring-after($style, 'color:'), ';', '')"/>
					</xsl:variable>
					<xsl:attribute name="color"><xsl:value-of select="$color"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="starts-with($style, 'size')">
					<xsl:variable name="size">
						<xsl:value-of select="translate(substring-after($style, 'size:'), ';', '')"/>
					</xsl:variable>
					<xsl:attribute name="font-size"><xsl:value-of select="$size"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="starts-with($style, 'font-family')">
					<xsl:variable name="face">
						<!--<xsl:value-of select="substring-before(substring-after($style, 'font-family:'), ',')"/>-->
						<xsl:value-of select="translate(substring-after($style, 'font-family:'), ';', '')"/>
					</xsl:variable>
					<xsl:attribute name="font-family"><xsl:value-of select="$face"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="starts-with($style, 'text-align')">
					<xsl:variable name="align">
						<xsl:value-of select="translate(substring-after($style, 'text-align:'), ';', '')"/>
					</xsl:variable>
					<xsl:attribute name="text-align"><xsl:value-of select="$align"/></xsl:attribute>
				</xsl:if>
			</xsl:if>
	</xsl:template>
	
	<!-- We render the <div> -->
	<xsl:template match="div">
		<fo:block>
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>
	
	<!-- For the <span> element, 
		we handle the font's color, family, and size attributes. Color will work if it's one 
		of the twelve colors supported by XSL-FO or it's a hex value like x0033ff. 
		(In other words, if you tell FOP to set the color to PapayaWhip, you're out 
		of luck.) The family attribute will work if FOP supports it. (There are ways 
		to add fonts to FOP, see the FOP documentation for more info.) Size is supported 
		for values like size="14pt". -->
	<xsl:template match="span">
		<fo:inline>
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- We render the <h1> -->
	<xsl:template match="h1">
		<fo:block font-size="28pt" line-height="32pt" keep-with-next="always" space-after="22pt">
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- <h2> is in a slightly smaller font than an <h1> -->
	<xsl:template match="h2">
		<fo:block font-size="24pt" line-height="28pt" keep-with-next="always" space-after="18pt">
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- <h3> is slightly smaller than <h2>. -->
	<xsl:template match="h3">
		<fo:block font-size="21pt" line-height="24pt" keep-with-next="always" space-after="14pt">
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- <h4> is smaller than <h3>. 
		For the bookmarks and table of contents, <h4> is the lowest level we include. -->
	<xsl:template match="h4">
		<fo:block font-size="18pt" line-height="21pt" keep-with-next="always" space-after="12pt">
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- <h5> is pretty small, and is underlined to help it stand out. -->
	<xsl:template match="h5">
		<fo:block font-size="16pt" line-height="19pt" keep-with-next="always" space-after="12pt" text-decoration="underline">
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- <h6> is the smallest heading of all, and is underlined and italicized. -->
	<xsl:template match="h6">
		<fo:block font-size="14pt" line-height="17pt" keep-with-next="always" space-after="12pt" font-style="italic" text-decoration="underline">
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- We render an <hr> with a leader. 
		Because <hr> is empty, we don't have to process any child elements. -->
	<xsl:template match="hr">
		<fo:block>
			<fo:leader leader-pattern="rule" rule-style="solid" 
				leader-length="100%" />
		</fo:block>
	</xsl:template>

	<!-- Italics. You can't get much simpler than that. -->
	<xsl:template match="i">
		<fo:inline font-style="italic">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- For the <img> element, 
		we use the src attribute as it comes from HTML. We also check for any width 
		and height attributes. If those attributes are there, we try to use them; 
		height="300px" is used as-is, while height="300" is converted to the value 
		"300px". -->
	<xsl:template match="img">
		<fo:wrapper>
			<fo:external-graphic src="{@src}">
				<xsl:if test="@width">
					<xsl:attribute name="width">
			            <xsl:choose>
			              <xsl:when test="contains(@width, 'px')">
			                <xsl:value-of select="@width" />
			              </xsl:when>
			              <xsl:otherwise>
			                <xsl:value-of select="concat(@width, 'px')" />
			              </xsl:otherwise>
			            </xsl:choose>
 		            </xsl:attribute>
				</xsl:if>
				<xsl:if test="@height">
					<xsl:attribute name="height">
			            <xsl:choose>
			              <xsl:when test="contains(@height, 'px')">
			                <xsl:value-of select="@height" />
			              </xsl:when>
			              <xsl:otherwise>
			                <xsl:value-of select="concat(@height, 'px')" />
			              </xsl:otherwise>
			            </xsl:choose>
		            </xsl:attribute>
				</xsl:if>
			</fo:external-graphic>
		</fo:wrapper>
	</xsl:template>

	<!-- The <kbd> element is in a slightly larger monospaced text. -->
	<xsl:template match="kbd">
		<fo:inline font-family="monospace" font-size="110%">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- We handle the <li> elements 
		under the <ol> and <ul> elements, so there's no <li> template here. -->

	<!-- For the <nobr> element, we simply turn off the wrap-option. -->
	<xsl:template match="nobr">
		<fo:inline wrap-option="no-wrap">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- We handle an ordered list 
		with two complications: If the list appears inside another list (either an 
		<ol> or <ul>), we don't put any vertical space after it. The other issue 
		is that we indent the list according to how deeply nested the list is. -->
	<xsl:template match="ol">
		<fo:list-block provisional-distance-between-starts="1cm"
			provisional-label-separation="0.5cm">
			<xsl:attribute name="space-after">
		        <xsl:choose>
		          <xsl:when test="ancestor::ul or ancestor::ol">
		            <xsl:text>0pt</xsl:text>
		          </xsl:when>
		          <xsl:otherwise>
		            <xsl:text>12pt</xsl:text>
		          </xsl:otherwise>
		        </xsl:choose>
		    </xsl:attribute>
			<xsl:attribute name="start-indent">
		        <xsl:variable name="ancestors">
		          <xsl:choose>
		            <xsl:when test="count(ancestor::ol) or count(ancestor::ul)">
		              <xsl:value-of
						select="1 + (count(ancestor::ol) + count(ancestor::ul)) * 1.25" />
		            </xsl:when>
		            <xsl:otherwise>
		              <xsl:text>1</xsl:text>
		            </xsl:otherwise>
		          </xsl:choose>
		        </xsl:variable>
		        <xsl:value-of select="concat($ancestors, 'cm')" />
	        </xsl:attribute>
			<xsl:apply-templates select="*" />
		</fo:list-block>
	</xsl:template>

	<!-- When we handle items in 
		an ordered list, we need to check if the list has a start attribute. If it 
		does, we change the starting number accordingly. Once we've figured out where 
		to start counting, we check the type attribute to see what format the numbers 
		should use. -->
	<xsl:template match="ol/li">
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block>
					<xsl:variable name="value-attr">
						<xsl:choose>
							<xsl:when test="../@start">
								<xsl:number value="position() + ../@start - 1" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:number value="position()" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="../@type='i'">
							<xsl:number value="$value-attr" format="i. " />
						</xsl:when>
						<xsl:when test="../@type='I'">
							<xsl:number value="$value-attr" format="I. " />
						</xsl:when>
						<xsl:when test="../@type='a'">
							<xsl:number value="$value-attr" format="a. " />
						</xsl:when>
						<xsl:when test="../@type='A'">
							<xsl:number value="$value-attr" format="A. " />
						</xsl:when>
						<xsl:otherwise>
							<xsl:number value="$value-attr" format="1. " />
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block>
					<xsl:apply-templates select="*|text()" />
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<!-- Your basic paragraph. -->
	<xsl:template match="p">
		<fo:block>
			<xsl:call-template name="checkStyle">
				<xsl:with-param name="style" select="@style"/>
			</xsl:call-template>
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- Preformatted text is rendered in a monospaced font. We also have to set the 
		wrap-option and white-space-collapse properties. -->
	<xsl:template match="pre">
		<fo:block font-family="monospace" white-space-collapse="false"
			wrap-option="no-wrap">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- Sample text is rendered in a slightly larger monospaced font. -->
	<xsl:template match="samp">
		<fo:inline font-family="monospace" font-size="110%">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- The <small> element is 
		rendered with a relative font size. That means putting one <small> element 
		inside another creates really small text. -->
	<xsl:template match="small">
		<fo:inline font-size="80%">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- For strikethrough text, we use the text-decoration property. -->
	<xsl:template match="strike">
		<fo:inline text-decoration="line-through">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- Strongly emphasized text is simply rendered in bold. -->
	<xsl:template match="strong">
		<fo:inline font-weight="bold">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- For subscript text, we use the vertical-align property and decrease the font size. -->
	<xsl:template match="sub">
		<fo:inline vertical-align="sub" font-size="75%">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- Superscript text changes the vertical-align property also, and uses a smaller font. -->
	<xsl:template match="sup">
		<fo:inline vertical-align="super" font-size="75%">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- Tables are a hassle. The main problem we have is converting the cols attribute into 
		some number of <fo:table-column> elements. We do this with a named template called build-columns. 
		Once we've processed the cols attribute, we invoke all of the templates for 
		the children of this element. -->
	<xsl:template match="table">
		<xsl:apply-templates select="caption"/>
		<fo:table width="100%" table-layout="fixed">
			<xsl:apply-templates select="tbody" />
		</fo:table>
	</xsl:template>

	<!-- Table's body -->
	<xsl:template match="tbody">
		<fo:table-body>
			<xsl:apply-templates select="*" />
		</fo:table-body>
	</xsl:template>
	
	<!-- Unfortunately FOP doesn't support <fo:table-caption>, so we use <fo:block> -->
	<!-- Table's caption -->
	<xsl:template match="caption">
		<fo:block text-align="center">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>
	
	<!-- For a table cell, we put everything inside a <fo:table-cell> element. 
		We set the padding property correctly, then we set the border style. 
		For the border style, we look to see if any of the ancestor elements we care about specified a solid border. 
		Next, we check for the rowspan, colspan, and align attributes. Notice that 
		for align, we check this element, then go up the ancestor chain until we 
		find the <table> element or we find something that specifies the alignment. -->
	<xsl:template match="td">
		<fo:table-cell padding-start="3pt" padding-end="3pt"
			padding-before="3pt" padding-after="3pt">
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
		          <xsl:value-of select="@colspan" />
		        </xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
		          <xsl:value-of select="@rowspan" />
		        </xsl:attribute>
			</xsl:if>
			<xsl:if
				test="@border='1' or 
                    ancestor::tr[@border='1'] or
                    ancestor::thead[@border='1'] or
                    ancestor::table[@border='1']">
				<xsl:attribute name="border-style">
		          <xsl:text>solid</xsl:text>
		        </xsl:attribute>
				<xsl:attribute name="border-color">
		          <xsl:text>black</xsl:text>
		        </xsl:attribute>
				<xsl:attribute name="border-width">
		          <xsl:text>1pt</xsl:text>
		        </xsl:attribute>
			</xsl:if>
			<xsl:variable name="align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:choose>
							<xsl:when test="@align='center'">
								<xsl:text>center</xsl:text>
							</xsl:when>
							<xsl:when test="@align='right'">
								<xsl:text>end</xsl:text>
							</xsl:when>
							<xsl:when test="@align='justify'">
								<xsl:text>justify</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>start</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="ancestor::tr[@align]">
						<xsl:choose>
							<xsl:when test="ancestor::tr/@align='center'">
								<xsl:text>center</xsl:text>
							</xsl:when>
							<xsl:when test="ancestor::tr/@align='right'">
								<xsl:text>end</xsl:text>
							</xsl:when>
							<xsl:when test="ancestor::tr/@align='justify'">
								<xsl:text>justify</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>start</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="ancestor::thead">
						<xsl:text>center</xsl:text>
					</xsl:when>
					<xsl:when test="ancestor::table[@align]">
						<xsl:choose>
							<xsl:when test="ancestor::table/@align='center'">
								<xsl:text>center</xsl:text>
							</xsl:when>
							<xsl:when test="ancestor::table/@align='right'">
								<xsl:text>end</xsl:text>
							</xsl:when>
							<xsl:when test="ancestor::table/@align='justify'">
								<xsl:text>justify</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>start</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>start</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<fo:block text-align="{$align}">
				<xsl:apply-templates select="*|text()" />
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<!-- The rarely-used <tfoot> element contains some number of <tr> elements;
		we just invoke the template	for <tr> here. -->
	<xsl:template match="tfoot">
		<xsl:apply-templates select="tr" />
	</xsl:template>

	<!-- If there's a <th> element, 
		we process it just like a normal <td>, except the font-weight is always bold 
		and the text-align is always center. -->
	<xsl:template match="th">
		<fo:table-cell padding-start="3pt" padding-end="3pt"
			padding-before="3pt" padding-after="3pt">
			<xsl:if test="@border='1' or 
                    ancestor::tr[@border='1'] or
                    ancestor::table[@border='1']">
				<xsl:attribute name="border-style">
		          <xsl:text>solid</xsl:text>
		        </xsl:attribute>
				<xsl:attribute name="border-color">
		          <xsl:text>black</xsl:text>
		        </xsl:attribute>
				<xsl:attribute name="border-width">
		          <xsl:text>1pt</xsl:text>
		        </xsl:attribute>
			</xsl:if>
			<fo:block font-weight="bold" text-align="center">
				<xsl:apply-templates select="*|text()" />
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<!-- Just like <tfoot>, the rarely-used <thead> element contains some number of table rows. 
		We just invoke the template for <tr> here. -->
	<xsl:template match="thead">
		<xsl:apply-templates select="tr" />
	</xsl:template>

	<!-- The title of the document is rendered in a large bold font, 
		centered on the page. This is the <title> 
		element in the <head> in <html>. -->
	<xsl:template match="title">
		<fo:block space-after="18pt" line-height="27pt" font-size="24pt"
			font-weight="bold" text-align="center">
			<xsl:apply-templates select="*|text()" />
		</fo:block>
	</xsl:template>

	<!-- For an HTML table row, we create an XSL-FO table row, 
		then invoke the templates for everything inside it. -->
	<xsl:template match="tr">
		<fo:table-row>
			<xsl:apply-templates select="*|text()" />
		</fo:table-row>
	</xsl:template>

	<!-- Teletype text is rendered in a monospaced font. -->
	<xsl:template match="tt">
		<fo:inline font-family="monospace">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- For underlined text, we use the text-decoration property. -->
	<xsl:template match="u">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

	<!-- The unordered list is 
		pretty straightforward; the only complication is calculating the space- after 
		and start-indent properties. If this list is inside another list, we don't 
		put any space after this one, and we calculate the indentation based on the 
		nesting level of this list. -->
	<xsl:template match="ul">
		<fo:list-block provisional-distance-between-starts="1cm"
			provisional-label-separation="0.5cm">
			<xsl:attribute name="space-after">
        <xsl:choose>
          <xsl:when test="ancestor::ul or ancestor::ol">
            <xsl:text>0pt</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>12pt</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
			<xsl:attribute name="start-indent">
		        <xsl:variable name="ancestors">
		          <xsl:choose>
		            <xsl:when test="count(ancestor::ol) or count(ancestor::ul)">
		              <xsl:value-of
						select="1 + (count(ancestor::ol) + count(ancestor::ul)) * 1.25" />
		            </xsl:when>
		            <xsl:otherwise>
		              <xsl:text>1</xsl:text>
		            </xsl:otherwise>
		          </xsl:choose>
		        </xsl:variable>
		        <xsl:value-of select="concat($ancestors, 'cm')" />
  	        </xsl:attribute>
			<xsl:apply-templates select="*" />
		</fo:list-block>
	</xsl:template>

	<!-- List items inside unordered lists are easy; 
		we just have to use the correct Unicode character for the bullet. -->
	<xsl:template match="ul/li">
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block>&#x2022;</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block>
					<xsl:apply-templates select="*|text()" />
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<!-- The <var> element is rendered in italics. -->
	<xsl:template match="var">
		<fo:inline font-style="italic">
			<xsl:apply-templates select="*|text()" />
		</fo:inline>
	</xsl:template>

</xsl:stylesheet>
