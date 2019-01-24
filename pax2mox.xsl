<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="2.0">
  <xsl:output method="xml" encoding="iso-8859-1" indent="yes"/>

  <!-- Stage 1: Pathways with duplicates

       We generate an XML file of pathways where each pathway
       contains the module entries from modules.xml it's told to by
       pathways.xml and, in addition, the module entries for anything
       listed as a prerequisite
  -->
  
  <xsl:variable name="pathwayswithduplicates">
    <pathways>
      <xsl:apply-templates select="//pathways" mode="withduplicates"/>
    </pathways>
  </xsl:variable>

  <!-- Stage 2: Tidying (sorting and removing duplicates)

       We generate an XML file for each pathway from the variable
       pathwayswithduplicates, in which each pathway is sorted (by
       year, then term) and has duplicate modules removed.
  -->

  <xsl:template match="/">
    <xsl:for-each select="/pathways/pathway">
      <xsl:variable name="id" select="./@id"/>
      <xsl:result-document href="pathway-{./@id}.xml">
	<xsl:apply-templates select="$pathwayswithduplicates" mode="tidying">
	  <xsl:with-param name="pathwayid" select="$id"/>
	</xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
    <!-- What follows is a chunk of code I was trying to use to
         generate the HTML page using XSL, which should be easy. I hit
         a problem, which maybe someone reading this can fix... for
         more, go down to the section "templates for HTML", also
         commented out...
	 
    <xsl:result-document href="pathways.html">
      <html>
	<head></head>
	<body>
	  <xsl:apply-templates select="/pathways/pathway" mode="html"/>
	</body>
      </html>
      </xsl:result-document>
      -->
  </xsl:template>


  <!-- Templates for the withduplicates stage -->
  
  <xsl:template match="pathways" mode="withduplicates">
    <xsl:apply-templates select="pathway" mode="withduplicates"/>
  </xsl:template>
    
  <xsl:template match="pathway" mode="withduplicates">
    <pathway>
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
      <xsl:choose>
	<xsl:when test="@id='y1y2'">
	  <!--
	      The first and second year modules can be extracted very
	      easily using an XPath query. -->
	  <xsl:for-each select="document('modules.xml')/modules/module[./year=1 or ./year=2]">
	    <xsl:copy-of select="."/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <!--
	      For all modules listed in the pathway, find the subset
	      of all nodes on which they depend and return a copy of
	      each node in this subset. on all prerequisite nodes. -->
	  <xsl:apply-templates select="includedmodule" mode="withduplicates"/>
	</xsl:otherwise>
      </xsl:choose>
    </pathway>
  </xsl:template>

  <xsl:template match="includedmodule" mode="withduplicates">
    <xsl:call-template name="returnmoduleandprerequisites">
      <xsl:with-param name="id">
	<xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- A recursive function which, when fed a module-id X, returns a
       copy of module X and then applies itself to any module-id for a
       module prerequisite for module X. -->
  
  <xsl:template name="returnmoduleandprerequisites">
    <xsl:param name="id"/>
    <xsl:copy-of select="document('modules.xml')/modules/module[./@id=$id]"/>
    <xsl:for-each select="document('modules.xml')/modules/module[./@id=$id]/prerequisites/prerequisite">
      <xsl:call-template name="returnmoduleandprerequisites">
	<xsl:with-param name="id">
	  <xsl:value-of select="."/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Templates for the tidying stage -->

  <xsl:template match="pathways" mode="tidying">
    <xsl:param name="pathwayid"/>
    <xsl:apply-templates select="pathway" mode="tidying">
      <xsl:with-param name="pathwayid" select="$pathwayid"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="pathway" mode="tidying">
    <xsl:param name="pathwayid"/>
    <xsl:if test="./@id=$pathwayid">
      <modules id="$pathwayid">
	<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
	<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
	<xsl:apply-templates select="module" mode="tidying">
	  <xsl:sort select="year" data-type="number"/>
	  <xsl:sort select="term" data-type="number"/>
	</xsl:apply-templates>
      </modules>
    </xsl:if>
  </xsl:template>

  <xsl:template match="module" mode="tidying">
    <xsl:if test="not(./@id=preceding-sibling::module/@id)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <!-- Templates for HTML stage

       The problem lies here. Inserting an img with src equal to the
       relevant SVG file means that useful properties of the SVG file
       (like hyperlinks to syllabi) are lost. Instead, you want
       something which inserts the svg file verbatim (minus its XML
       header). Annoyingly, I couldn't figure out how to do that in
       XSL. Instead, I rely on the shell script pipeline.sh which does
       it by brute force.

  <xsl:template match="pathway" mode="html">
    
    <h1><xsl:value-of select="./@name"/></h1>

    <img>
      <xsl:attribute name="src">pathway-<xsl:value-of select="./@id"/>.svg</xsl:attribute>
    </img>
  </xsl:template>
  -->
  
</xsl:transform>
