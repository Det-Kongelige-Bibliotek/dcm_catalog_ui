xquery version "1.0" encoding "UTF-8";

declare namespace loop="http://kb.dk/this/getlist";

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


declare function loop:clean-names ($key as xs:string) as xs:string
{
  (: strip off any text not part of the name (marked with a comma or parentheses) :)
  let $txt := concat(translate(normalize-space($key),',;(','***'),'*')
  return substring-before($txt,'*') 
};

declare function loop:simplify-list ($key as xs:string) as xs:string
{
  (: strip off anything following the first volume reference :)
  let $txt := concat(translate(normalize-space($key),' ,;()-–','*******'),'*')
  return substring-before($txt,'*')
};

declare function loop:clean-volumes ($key as xs:string) as xs:string
{
  (: format the volume numbers for display :)
  let $txt := concat(translate(normalize-space($key),' ,;()','*****'),'*')
  return substring-before($txt,'*')
};


<html xmlns="http://www.w3.org/1999/xhtml">
	<body>
	
    <div>
    CNS: 
		    {
            	    for $c in distinct-values(
            		collection($database)//m:workDesc/m:work/m:identifier[@label='CNS']/string()[string-length(.) > 0
            		and not(number(.))])
                    order by number($c)
            	    return 
            	       <div>{$c}</div>

            }

    </div>
    <div>
Names: 
		    {
            	    for $c in distinct-values(
            		collection($database)//m:persName[not(name(..)='respStmt' and name(../..)='pubStmt' and name(../../..)='fileDesc')]
            		/string()[string-length(.) > 0 and not(contains(.,'Carl Nielsen'))])
                    order by $c
            	    return 
            	       <div>&gt;{$c}&lt;</div>

            }
    </div>

  </body>
</html>
