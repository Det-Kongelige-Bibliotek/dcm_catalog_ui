xquery version "1.0" encoding "UTF-8";

import module namespace layout="http://kb.dk/this/app/layout" at "./cnw-layout.xqm";
declare option exist:serialize "method=xml media-type=text/html;charset=UTF-8";
declare variable $mode   := request:get-parameter("mode","") cast as xs:string;

<html xmlns="http://www.w3.org/1999/xhtml">
  {layout:head("About Carl Nielsen Works (CNW)",(),false())}
  <body class="list_files">
    <div id="all">
      {layout:page-head("CNW","A Thematic Catalogue of Carl Nielsen&apos;s Works")}
      {layout:page-menu($mode)}
      <div id="main">
	<p>
	A major theme of poststructuralism is instability in the human
	sciences, due to the complexity of humans themselves.
	</p>
	<p>
	And the impossibility of fully escaping structures in order to study
	them.  
	</p>
	<p>
	And the impossibility of fully escaping structures in order
	to study them.
	</p>
	<p>
	And the impossibility of fully escaping structures in
	order to study them.
	</p>
	<p>
	And the impossibility of fully escaping structures in order
 	to study them.
	</p>
	<p>
	And the impossibility of fully escaping structures in
	order to study them.
	</p>
      </div>
      {layout:page-footer($mode)}
    </div>
  </body>
</html>

