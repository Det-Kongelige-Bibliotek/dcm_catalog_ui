xquery version "1.0" encoding "UTF-8";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $database := "/db/cnw/data";


<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

    <h1>English titles and first lines</h1>
    <h2>All titles: <i>Title</i> (First line)</h2>
    <div>
            
		    {

            	    for $c in collection($database)/m:mei/m:meiHead/m:workDesc/m:work
                    order by $c/m:titleStmt/m:title[@xml:lang='en' or count($c/m:titleStmt/m:title[@xml:lang='en'])=0][1]/string()
            	    return
            	       <div>
            	       {
            	           (: English title (English first line) :)
                            let $output :=
                            if ($c/m:titleStmt/m:title[@type='main' or not(@type)][@xml:lang='en']) then
                              if(fn:string-length($c/m:titleStmt/m:title[@type='main' or not(@type)][@xml:lang='en'][1])>0 
                              and fn:string-length($c/m:titleStmt/m:title[@type='alternative'][@xml:lang='en'][1])>0) then
                                <span>
                                    <i>{$c/m:titleStmt/m:title[@type='main' or not(@type)][@xml:lang='en'][1]/string()} </i>{
                                    $c/m:titleStmt/m:title[@type='subordinate'][@xml:lang='en'][1]/string()}
                                    {fn:concat(' (',$c/m:titleStmt/m:title[@type='alternative'][@xml:lang='en'][1]/string(),') ')
                                }</span>
                              else 
                                fn:concat($c/m:titleStmt/m:title[@type='main' or not(@type)][@xml:lang='en'][1]/string(),' ',
                                $c/m:titleStmt/m:title[@type='subordinate'][@xml:lang='en'][1]/string()) 
                            else 
                              (: no English title; use first title instead :)
                              if(fn:string-length($c/m:titleStmt/m:title[@type='alternative'][@xml:lang='en'][1])>0) then
                                <span>
                                    <i>{$c/m:titleStmt/m:title[@type='main' or not(@type)][1]/string()} </i>{
                                    $c/m:titleStmt/m:title[@type='subordinate'][@xml:lang='en'][1]/string()}
                                    {fn:concat(' (',$c/m:titleStmt/m:title[@type='alternative'][@xml:lang='en'][1]/string(),') ')
                                }</span>
                              else 
                                fn:concat($c/m:titleStmt/m:title[@type='main' or not(@type)][1]/string(),' ',
                                $c/m:titleStmt/m:title[@type='subordinate'][@xml:lang='en'][1]/string()) 

                            return $output
                         }
                         { fn:concat(' CNW ',$c/m:identifier[@label='CNW']/string())}
                         </div>

            }
    </div>

    <h2>First line (<i>Title</i>)</h2>
    <div>
            
		    {

            	    for $c in collection($database)/m:mei/m:meiHead/m:workDesc/m:work[m:titleStmt/m:title[@type='alternative' and @xml:lang='en']]
                    order by $c/m:titleStmt/m:title[@type='alternative'][@xml:lang='en'][1]/string()
            	    return
            	       <div>
            	       {
            	           (: English first line (English title) :)
                            let $output := 
                                <span>
                                    {fn:concat($c/m:titleStmt/m:title[@type='alternative'][@xml:lang='en'][1]/string(),' (')}
                                    <i>{
                                    let $main:=
                                    if(fn:string-length($c/m:titleStmt/m:title[@type='main' or not(@type)][@xml:lang='en'][1]/string()) > 0) then
                                        $c/m:titleStmt/m:title[@type='main' or not(@type)][@xml:lang='en'][1]/string()
                                    else
                                        $c/m:titleStmt/m:title[@type='main' or not(@type)][1]/string()
                                    return $main
                                    }</i>{
                                    let $sub:=
                                    if(fn:string-length($c/m:titleStmt/m:title[@type='subordinate'][@xml:lang='en'][1]/string()) > 0) then
                                        fn:concat(' ',$c/m:titleStmt/m:title[@type='subordinate'][@xml:lang='en'][1]/string())
                                    else
                                        ''
                                    return fn:concat($sub,')') }
                                </span>

                            return $output
                         }
                         { fn:concat(' CNW ',$c/m:identifier[@label='CNW']/string())}
                         </div>

            }
    </div>


  </body>
</html>