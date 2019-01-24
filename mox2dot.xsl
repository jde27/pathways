<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="2.0">
  <xsl:output method="text" encoding="iso-8859-1" indent="yes"/>
  
  <!-- A prefix variable used for generating URLs -->
  
  <xsl:variable name="prefix">
    <xsl:value-of select="document('modules.xml')/modules/linkprefix"/>
  </xsl:variable>

  <xsl:template match="/">
    digraph <xsl:value-of select="/modules/@id"/>{
        node [shape = box,style="filled,bold",fillcolor="white",penwidth=5];
        <xsl:apply-templates select="//module" mode="dotnodes"/>

	<xsl:for-each-group select="//module" group-by="year">
	  <xsl:for-each-group select="current-group()" group-by="term">
	    {rank=same;<xsl:for-each select="current-group()"><xsl:value-of select="@id"/>;</xsl:for-each>};
	  </xsl:for-each-group>
	</xsl:for-each-group>
  	
        <xsl:apply-templates select="//prerequisite" mode="dotarrows"/>
    }
  </xsl:template>

  <xsl:template match="module" mode="dotnodes">
    <xsl:variable name="color">
      <xsl:choose>
        <xsl:when test="./year=1">orange</xsl:when>
        <xsl:when test="./year=2 and ./term=1">green3</xsl:when>
        <xsl:when test="./year=2 and ./term=2">cadetblue</xsl:when>
        <xsl:when test="./year=3">brown1</xsl:when>
	<xsl:when test="./year=3.5">deeppink</xsl:when>
	<xsl:when test="./year=4">midnightblue</xsl:when>
	<xsl:otherwise>white</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="./@id"/> [label = "<xsl:value-of select="./code/current"/>\n<xsl:value-of select="./name"/>",href="<xsl:value-of select="$prefix"/><xsl:value-of select="./syllabus"/>",color="<xsl:value-of select="$color"/>"];
  </xsl:template>

  <xsl:template match="prerequisite" mode="dotarrows">
    <xsl:variable name="decoration">
      <xsl:choose>
	<xsl:when test="./@type='recommended'">dashed</xsl:when>
	<xsl:otherwise>solid</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="."/> -> <xsl:value-of select="../../@id"/> [style = <xsl:value-of select="$decoration"/>];
  </xsl:template>

</xsl:transform>
