# Introduction #

The pyang -f tree generates an ASCII based tree representation that is great for navigating the model.
There are two new (soon to be released) tree representations
  * Javascript tree: `pyang -f jstree`
  * Hyperbolic tree: `pyang -f hypertree`

## Javascript Tree ##
The Javascript tree output creates a html/javascript page with the model:

![https://pyang.googlecode.com/svn/trunk/doc/img/js.png](https://pyang.googlecode.com/svn/trunk/doc/img/js.png)

You can  [try it ](http://yang-central.org/tmp/ietf-netconf-acm.htm) on the YANG module for access control [RFC6536](http://tools.ietf.org/html/rfc6536).

A larger example [ipfix](http://yang-central.org/tmp/ipfix.html)


## Hyperbolic Tree ##
For very large models a traditional tree can be hard to navigate. A [hyperbolic tree](http://en.wikipedia.org/wiki/Hyperbolic_tree) can help.
Personally I am not convinced if a get help or get dizzy.
The hyperbolic output generates an xml file that can be displayed in [Treebolic](http://treebolic.sourceforge.net/):

![https://pyang.googlecode.com/svn/trunk/doc/img/ht.png](https://pyang.googlecode.com/svn/trunk/doc/img/ht.png).


[Try it](http://yang-central.org/tmp/ipfix-hypertree.html) for the large ipfix model.

Generate the file:
```
pyang -f hypertree ietf-ipfix.yang -o ietf-ipfix.xml
```


In order to use the xml file, put the `TreebolicAppletDom.jar` in a proper location. Write a small html file like:

```
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf8">
<title>IETF IPFIX</title>
</head>

<body bgcolor="#3A6EA5" text="#FFFFFF" link="#FF0000" vlink="#FFFFFF">

<applet code="treebolic.applet.Treebolic.class" archive="TreebolicAppletDom.jar" id="Treebolic" width="100%" height="100%">
  <param name="doc" value="ietf-ipfix.xml">
</applet>

</body>

</html>

```