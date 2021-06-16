xquery version "1.0" encoding "UTF-8";

module  namespace loop="http://kb.dk/this/getlist";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace filter="http://kb.dk/this/app/filter";

declare variable $loop:sortby       := "null,work_number";

declare variable $loop:coll         := request:get-parameter("c","") cast as xs:string;
declare variable $loop:vocabulary   := doc(concat("/db/cat-site/",$loop:coll,"/keywords.xml"));

declare variable $loop:identifiers := doc("/db/cat-site/collections.xml");
(:declare variable $loop:collection   := upper-case($loop:coll);:)
declare variable $loop:collection   := $loop:identifiers//*[m:title=$loop:coll]/m:identifier;

declare variable $loop:notbefore    := request:get-parameter("notbefore","") cast as xs:string;
declare variable $loop:notafter     := request:get-parameter("notafter","") cast as xs:string;
declare variable $loop:minyear      := request:get-parameter("minyear",$filter:settings/m:mei/m:date[@type="yearSelection"]/@notbefore) cast as xs:integer;
declare variable $loop:maxyear      := request:get-parameter("maxyear",$filter:settings/m:mei/m:date[@type="yearSelection"]/@notafter) cast as xs:integer;
declare variable $loop:query_string := request:get-parameter("query","");
declare variable $loop:page         := request:get-parameter("page","1") cast as xs:integer;
declare variable $loop:number       := request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $loop:genre        := request:get-parameter("genre","") cast as xs:string;

declare variable $loop:title        := request:get-parameter("title", "") cast as xs:string;
declare variable $loop:name         := request:get-parameter("name", "") cast as xs:string;
declare variable $loop:scheme       := request:get-parameter("scheme",$loop:collection) cast as xs:string;
declare variable $loop:workno       := request:get-parameter("workno", "") cast as xs:string;

declare function loop:valid-work-number($doc as node()) as xs:boolean
{
  (: this is CNW-specific and can be safely ignored; returns true in all other contexts :)
  let $exclude := request:get-parameter("anthologies", "")
  let $result  := 
    if($loop:collection eq "CNW") then
      if($exclude eq "yes") then
	   let $num:=fn:number($doc//m:workList/m:work/m:identifier[@label=$loop:collection ][1]/string())
	   return $num >= 1 and 9999 >= $num
      else
       true()
    else
      true()
  return $result
};

declare function loop:padded-numbers ($key as xs:string) as xs:string
{
  (: extract any trailing number :)
  let $number:= replace($key,'^.*?(\d*)$','$1')
  (: and anything that might be before the number :)
  let $prefix:= replace($key,'^(.*?)\d*$','$1')
  (: make the number a 15 character long string padded with zeros :)
  let $padded_number:=concat("0000000000000000",normalize-space($number))
  let $len:=string-length($padded_number)-14
  return concat($prefix,substring($padded_number,$len,15))
};


declare function loop:date-filters(
  $doc as node()) as xs:boolean
{
  let $get_notbefore:= request:get-parameter("notbefore","")
  let $notbefore := 
    if(fn:number($get_notbefore) > 0) then
        fn:number($get_notbefore)
    else
        0

  let $get_notafter := request:get-parameter("notafter","")
  let $notafter := 
    if(fn:number($get_notafter) < 2100) then
        fn:number($get_notafter)
    else
        9999
                

  let $date := 
    for $d in $doc//m:workList/m:work/m:creation/m:date
      return $d
    
  let $earliest := 
    if($date[1]/@notbefore/string()) then
      fn:number(substring($date[1]/@notbefore/string(),1,4))
    else if ($date[1]/@startdate/string()) then
      fn:number(substring($date[1]/@startdate/string(),1,4))
    else if ($date[1]/@isodate/string()) then
      fn:number(substring($date[1]/@isodate/string(),1,4))
    else
      $loop:minyear

  let $latest   := 
    if($date[1]/@notafter/string()) then
      fn:number(substring($date[1]/@notafter/string(),1,4))
    else if ($date[1]/@enddate/string()) then 
      fn:number(substring($date[1]/@enddate/string(),1,4))
    else if ($date[1]/@isodate/string()) then 
      fn:number(substring($date[1]/@isodate/string(),1,4))
    else
      $loop:maxyear

      
  let $inside := ($earliest>=$notbefore and $earliest<=$notafter) or ($latest>=$notbefore and $latest<=$notafter)       

  return $inside

};

declare function loop:genre-filter(
  $genre as xs:string,
  $doc as node()) as xs:boolean
{
  (: we are searching in level 2 genre keywords :)

  let $docgenre1 := string-join($doc//m:workList/m:work/m:classification/m:termList/m:term[.=$loop:vocabulary//m:taxonomy/m:category/m:desc and .!='']/string(), " ")
  let $docgenre2 := string-join($doc//m:workList/m:work/m:classification/m:termList/m:term[.=$loop:vocabulary//m:taxonomy/m:category/m:category/m:desc and .!='']/string(), " ")

  let $occurrence :=
    if( string-length($genre)=0) then
      true()
    else 
      if(contains($docgenre1,$genre) ) then
	true()
      else if( contains($docgenre2,$genre) ) then
	true()
      else
	false()

      return $occurrence
};

declare function loop:sort-key (
  $doc as node(),
  $key as xs:string) as xs:string
{

  let $sort_key:=
    if($key eq "person") then
      replace(lower-case($doc//m:workList/m:work/m:contributor[@role="composer" or @role="cmp"]/string()),"\\\\ ","")
    else if($key eq "title") then
      replace(lower-case($doc//m:workList/m:work/m:title[1]/string()),"\\\\ ","")
    else if($key eq "date") then
      let $dates := 
          for $date in $doc//m:workList/m:work/m:creation/m:date/(@notafter|@isodate|@notbefore|@startdate|@enddate)
	    return substring($date,1,4)
      return 
	if(count($dates)>=1) then
	  max($dates)
	else
	  "0000"
    else if($key eq "work_number" and $doc//m:workList/m:work/m:identifier/@label[.=$loop:collection]/../string()) then
      (: make the number a 15 character long string padded with zeros :)
      (: let $num:=$doc//m:workList/m:work/m:identifier[@label=$loop:collection][1]/string():)
      (: let $num:=$doc//m:workList/m:work/m:identifier[@label=$doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]][1]/string() :)
      (: workaround to avoid random duplicates :)
      
      (: was: let $num:=$doc//m:workList/m:work/m:identifier/@label[.=$loop:collection]/../string() 
      let $padded_number:=concat("0000000000000000",normalize-space($num))
      let $len:=string-length($padded_number)-14  
	return substring($padded_number,$len,15) :)
	   
	   loop:padded-numbers($doc//m:workList/m:work/m:identifier/@label[.=$loop:collection]/../string())
	
    else 
      ""

  return $sort_key

};

declare function loop:getlist (
  $database        as xs:string,
  $genre           as xs:string,
  $query           as xs:string) as node()* 
  {
    let $sortby := request:get-parameter("sortby",$loop:sortby)
    let $sort0  := substring-before($sortby,",")
    let $sort1  := substring-after($sortby,",")

    let $list   := 
      for $doc in 
				collection($database)/m:mei[
          (not($query) or ft:query(.,$query)) 
          and
					(not($loop:title) or ft:query(.//m:title,$loop:title))
					and
					(not($loop:name)  or ft:query(.//m:contributor|.//m:recipient|.//m:author|.//m:persName,concat('&quot;',$loop:name,'&quot;')))
					and
					(not($loop:workno) 
					or .//m:identifier[ft:query(@label,$loop:scheme) and ft:query(.,concat('&quot;',$loop:workno,'&quot;'))] )]
      where 
				loop:genre-filter($genre,$doc) and 
				loop:date-filters($doc) and 
				loop:valid-work-number($doc) 
      order by loop:sort-key ($doc,$sort0),loop:sort-key($doc,$sort1)
      return $doc	    
    return $list
};
