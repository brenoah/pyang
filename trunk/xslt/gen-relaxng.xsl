<?xml version="1.0" encoding="utf-8"?>

<!-- Program name: gen-relaxng.xsl

Copyright © 2010 by Ladislav Lhotka, CESNET <lhotka@cesnet.cz>

Creates standalone RELAX NG schema from conceptual tree schema.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:nma="urn:ietf:params:xml:ns:netmod:dsdl-annotations:1"
                xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"                version="1.0">

  <xsl:output method="xml" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:include href="gen-common.xsl"/>

  <xsl:template name="ns-attribute">
    <xsl:if test="$target!='dstore'">
      <xsl:attribute name="ns">
        <xsl:choose>
          <xsl:when test="$target='get-reply' or $target='getconf-reply'
                          or $target='rpc' or $target='rpc-reply'">
            <xsl:text>urn:ietf:params:xml:ns:netconf:base:1.0</xsl:text>
          </xsl:when>
          <xsl:when test="$target='notif'">
            <xsl:text>urn:ietf:params:xml:ns:netconf:notification:1.0</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="force-choice">
    <xsl:choose>
      <xsl:when test="rng:interleave">
        <xsl:element name="choice" namespace="{$rng-uri}">
          <xsl:apply-templates select="rng:interleave/*"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="message-id">
    <xsl:element name="ref" namespace="{$rng-uri}">
      <xsl:attribute name="name">message-id-attribute</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/">
    <xsl:call-template name="check-input-pars"/>
    <xsl:choose>
      <xsl:when test="$gdefs-only=1">
        <xsl:apply-templates select="rng:grammar" mode="gdefs"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="rng:grammar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/rng:grammar" mode="gdefs">
    <xsl:element name="grammar" namespace="{$rng-uri}">
      <xsl:attribute name="datatypeLibrary">
        <xsl:value-of select="@datatypeLibrary"/>
      </xsl:attribute>
      <xsl:apply-templates select="rng:define"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/rng:grammar">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="ns-attribute"/>
      <xsl:element name="include" namespace="{$rng-uri}">
        <xsl:attribute name="href">
          <xsl:value-of select="$rng-lib"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="rng:start"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/rng:grammar/rng:start">
    <xsl:copy>
      <xsl:apply-templates select="rng:element[@name='nmt:netmod-tree']"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="rng:element[@name='nmt:netmod-tree']">
    <xsl:choose>
      <xsl:when test="$target='dstore'">
        <xsl:call-template name="force-choice"/>
      </xsl:when>
      <xsl:when test="$target='get-reply' or $target='getconf-reply'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">rpc-reply</xsl:attribute>
          <xsl:call-template name="message-id"/>
          <xsl:element name="element" namespace="{$rng-uri}">
            <xsl:attribute name="name">data</xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$target='rpc'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">rpc</xsl:attribute>
          <xsl:call-template name="message-id"/>
          <xsl:call-template name="force-choice"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$target='rpc-reply'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">rpc-reply</xsl:attribute>
          <xsl:call-template name="message-id"/>
          <xsl:if test="descendant::rpc[not(nmt:output)]">
            <xsl:element name="ref" namespace="{$rng-uri}">
              <xsl:attribute name="name">ok-element</xsl:attribute>
            </xsl:element>
          </xsl:if>
          <xsl:call-template name="force-choice"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$target='notif'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">notification</xsl:attribute>
          <xsl:element name="ref" namespace="{$rng-uri}">
            <xsl:attribute name="name">eventTime-element</xsl:attribute>
          </xsl:element>
          <xsl:call-template name="force-choice"/>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:grammar">
    <xsl:choose>
      <xsl:when test="$target='dstore' or $target='get-reply'
                      or $target='getconf-reply'">
        <xsl:call-template name="inner-grammar">
          <xsl:with-param
              name="subtrees"
              select="descendant::rng:element[@name='nmt:data']"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$target='rpc'">
        <xsl:call-template name="inner-grammar">
          <xsl:with-param
              name="subtrees"
              select="descendant::rng:element[@name='nmt:input']"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$target='rpc-reply'">
        <xsl:call-template name="inner-grammar">
          <xsl:with-param
              name="subtrees"
              select="descendant::rng:element[@name='nmt:output']"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$target='notif'">
        <xsl:call-template name="inner-grammar">
          <xsl:with-param
              name="subtrees"
              select="descendant::rng:element[@name='nmt:notification']"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="inner-grammar">
    <xsl:param name="subtrees"/>
    <xsl:if test="$subtrees">
      <xsl:element name="grammar" namespace="{$rng-uri}">
        <xsl:attribute name="ns">
          <xsl:value-of select="@ns"/>
        </xsl:attribute>
        <xsl:if test="/rng:grammar/rng:define">
          <xsl:element name="include" namespace="{$rng-uri}">
            <xsl:attribute name="href">
              <xsl:value-of select="concat($basename,'-gdefs.rng')"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:if>
      <xsl:element name="start" namespace="{$rng-uri}">
        <xsl:apply-templates select="$subtrees"/>
      </xsl:element>
      <xsl:apply-templates select="rng:define"/>
    </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rng:element[@name='nmt:data']">
    <xsl:choose>
      <xsl:when test="$target='dstore'">
        <xsl:call-template name="force-choice">
          <xsl:with-param name="todo" select="rng:*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="count(rng:*)>1">
        <xsl:element name="interleave" namespace="{$rng-uri}">
          <xsl:apply-templates select="rng:*"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="rng:*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:element[@name='nmt:notification'
                       or @name='nmt:input' or @name='nmt:output']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@nma:*|nma:*|a:*"/>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="rng:optional">
    <xsl:choose>
      <xsl:when test="$target='dstore' and
                      (parent::rng:element/@name='nmt:data' or
                      parent::rng:interleave/
                      parent::rng:element/@name='nmt:data')">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="$target='getconf-reply'
                        and @nma:config='false'">
          <xsl:element name="notAllowed" namespace="{$rng-uri}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*|text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>