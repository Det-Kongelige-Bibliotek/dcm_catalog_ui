xquery version "1.0" encoding "UTF-8";
module namespace loop="http://kb.dk/this/getlist";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace util="http://exist-db.org/xquery/util";

declare variable $loop:vocabulary := 
  doc(concat("http://",request:get-header('HOST'),"/editor/forms/mei/model/keywords.xml"));

declare function loop:valid-work-number(
  $doc as node(),
  $coll as xs:string) as xs:boolean
{
  let $result := 
    if(not(lower-case($coll) = "cnw")) then
      true()
    else
      let $num:=fn:number($doc//m:workDesc/m:work/m:identifier[@type=$coll]/string())
      return $num >= 1 and 413 >= $num

  return $result
};
  

declare function loop:date-filters(
  $doc as node()) as xs:boolean
{
  let $notafter := request:get-parameter("notafter","")
  let $notbefore:= request:get-parameter("notbefore","")

  let $date := 
    for $d in $doc//m:workDesc/m:work/m:history/m:creation/m:date
      return $d
    
  let $earliest := 
    if($date/@notbefore/string()) then
      substring($date/@notbefore/string(),1,4)
    else if ($date/@isodate/string()) then
      substring($date/@isodate/string(),1,4)
    else
      ""

  let $latest   := 
    if($date/@notafter/string()) then
      substring($date/@notafter/string(),1,4)
    else if ($date/@isodate/string()) then 
      substring($date/@isodate/string(),1,4)
    else
      ""

  let $inside := 
    if( $notafter and $notbefore ) then
      ($notafter >= $latest and $notbefore <= $earliest)
    else
      true()
      
  return $inside

};

declare function loop:genre-filter(
  $genre as xs:string,
  $doc as node()) as xs:boolean
{
  (: we are searchin in level 2 genre keywords :)

  let $docgenre1 := $doc//m:workDesc/m:work/m:classification/m:termList/m:term[.=$loop:vocabulary//m:termList[@label='level1']/m:term and .!=''][1]/string()
  let $docgenre2 := $doc//m:workDesc/m:work/m:classification/m:termList/m:term[.=$loop:vocabulary//m:termList[@label='level2']/m:term and .!=''][1]/string()

  let $occurrence :=
    if( string-length($genre)=0) then
      true()
    else 
      if($genre eq $docgenre1 ) then
	true()
      else if($genre eq $docgenre2) then
	true()
      else
	false()

      return $occurrence
};


declare function loop:pubstatus(
	$published_only  as xs:string,
	$doc as node())  as xs:boolean 
{
  let $uri         := concat("/db/public/",util:document-name($doc))
  let $dcm_hash    := util:hash($doc,'md5')

  let $status := 
    if( not($published_only) ) then
      true()
    else
      if( doc-available($uri)) then
	let $public_hash := util:hash(doc($uri),'md5')
	return
	if ($published_only eq 'pending' and $public_hash ne $dcm_hash) then
	  true()
	else 
	  if($published_only eq 'any') then
	    true()
	  else
	    false()
      else
	if($published_only eq 'unpublished') then
	  true()
	else 
	  false()

   return $status

};

declare function loop:sort-key (
  $doc as node(),
  $key as xs:string) as xs:string
{

  let $collection:=$doc//m:seriesStmt/m:identifier[@type="file_collection"]/string()[1] 

  let $sort_key:=
    if($key eq "person") then
      replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:respStmt/m:persName[1]/string()),"\\\\ ","")
    else if($key eq "title") then
      replace(lower-case($doc//m:workDesc/m:work[@analog="frbr:work"]/m:titleStmt[1]/m:title[1]/string()),"\\\\ ","")
    else if($key eq "date") then
      substring($doc//m:workDesc/m:work/m:history/m:creation/m:date/(@notafter|@isodate|@notbefore)[1],1,4)
    else if($key eq "work_number") then
      (: make the number a 5 character long string padded with zeros :)
      let $num:=$doc//m:workDesc/m:work/m:identifier[@type=$collection]/string()
      let $padded_number:=concat("000000",normalize-space($num))
      let $len:=string-length($padded_number)-4
	return substring($padded_number,$len,5)
    else 
      ""

  return $sort_key

};

declare function loop:getlist (
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $genre           as xs:string,
  $query           as xs:string) as node()* 
  {
    let $sortby := request:get-parameter("sortby","person,title")
    let $sort0  := substring-before($sortby,",")
    let $sort1  := substring-after($sortby,",")
    let $list   := 
      if($coll) then 
	if($query) then
          for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll  and ft:query(.,$query)] 
          where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc) and loop:date-filters($doc) and loop:valid-work-number($doc,$coll)
	  order by loop:sort-key ($doc,$sort0),loop:sort-key($doc,$sort1)
	  return $doc 
	else
	  for $doc in collection($database)/m:mei[m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll] 
          where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc) and loop:date-filters($doc) and loop:valid-work-number($doc,$coll)
	  order by loop:sort-key ($doc,$sort0),loop:sort-key($doc,$sort1)
	  return $doc 
        else
	  if($query) then
            for $doc in collection($database)/m:mei[ft:query(.,$query)]
            where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc) and loop:date-filters($doc) and loop:valid-work-number($doc,$coll)
	    order by loop:sort-key ($doc,$sort0),loop:sort-key($doc,$sort1)
	    return $doc
      else
        for $doc in collection($database)/m:mei
        where loop:pubstatus($published_only,$doc) and loop:genre-filter($genre,$doc) and loop:date-filters($doc) and loop:valid-work-number($doc,$coll)
	order by loop:sort-key ($doc,$sort0),loop:sort-key($doc,$sort1)
	return $doc
	      
    return $list

  };

