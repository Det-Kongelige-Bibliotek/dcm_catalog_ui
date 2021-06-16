xquery version "1.0" encoding "UTF-8";

module  namespace  layout="http://kb.dk/this/app/layout";
declare namespace  h="http://www.w3.org/1999/xhtml";
declare namespace  m="http://www.music-encoding.org/ns/mei";

declare variable $layout:coll     := request:get-parameter("c","") cast as xs:string;

declare function layout:head($title as xs:string,
                             $additions as node()*,
                             $verovio as xs:boolean
			) as node() 
{
  let $head :=
  <head>
    <title>{$title}</title>
      
    <meta http-equiv="Content-Type" content="application/xhtml+xml;charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    
    <link rel="icon" type="image/vnd.microsoft.icon" href="favicon.ico" />
      
    <link type="text/css" 
          href="style/dcm.css" 
	  rel="stylesheet" />

   {$additions}

    <link type="text/css" 
          href="style/{$layout:coll}/collection.css" 
	  rel="stylesheet" />

    <link href="jquery/jquery-ui-1.10.3/css/base/jquery-ui.css" 
       rel="stylesheet" 
       type="text/css"/>

    <link href="jquery/jquery-ui-1.10.3/css/style.css" 
       rel="stylesheet"  
       type="text/css"/>
      
    <script type="text/javascript" src="js/swap_num_type.js">
      //
    </script>

    <script type="text/javascript" src="js/filter.js">
      //
    </script>
      
    <script type="text/javascript" src="jquery/jquery-ui-1.10.3/js/jquery-1.9.1.js">
      //
    </script>

    <script type="text/javascript" src="jquery/jquery-ui-1.10.3/js/jquery-ui-1.10.3.custom.js">
      //
    </script>
    
    <!-- insert slider.js script here to activate the year slider -->
    
    <script type="text/javascript" src="js/google_analytics.js">
    //
    </script>
    
    { if($verovio) then   
			<script src="http://www.verovio.org/javascript/latest/verovio-toolkit-light.js" type="text/javascript">
			//
			</script>
    else () }
    
    { if($verovio) then   
			<script type="text/javascript">
				/* Create the Verovio toolkit instance */
				var vrvToolkit = new verovio.toolkit();
			</script>
    else () }
    
    
  </head>

  return $head

};

declare function layout:page-head-doc($html as node()) as node()
{
	let $div :=
		for $t in $html//h:title
			let $tit := 
				if($t/@id) then
					$t/@id
				else
					""
			let $sub :=
				if($t/text()) then
					$t/text()
				else
					""
			return 
				layout:page-head($tit,$sub)

		return $div
};

declare function layout:page-head(
                        $title as xs:string,
			$subtitle as xs:string) as node()
{
  let $header :=
  <div id="header">
    <div class="kb_logo">
      <a href="http://www.kb.dk" title="Det Kgl. Bibliotek"><img
         id="KBLogo"
	 title="Det Kgl. Bibliotek" 
	 alt="KB Logo" src="style/images/kb_white.png"/><img
	 id="KBLogo_print"
	 title="Det Kgl. Bibliotek" 
	 alt="KB Logo" src="style/images/kb.png"
	 /></a>
    </div>
    <h1>
    <a style="text-decoration:none;" 
       href="http://www.kb.dk/dcm/{$layout:coll}.html" 
       title="{$title} – {$subtitle}">{$title}</a></h1>
    <h2><a style="text-decoration:none;" href="http://www.kb.dk/dcm/{$layout:coll}.html" title="{$title} – {$subtitle}">{$subtitle}</a></h2>
  </div>

  return $header

};

declare function layout:page-menu($mode as xs:string) as node()
{

  let $menudoc  :=
  <div id="menu" class="noprint"> {
  for $anchor in doc(concat("/db/cat-site/",$layout:coll,"/menu.html"))/div/a
    return 
      if(contains($anchor/@href,$mode)) then
	<a href="{$anchor/@href}" class="selected">{$anchor/text()}</a>
      else
	<a href="{$anchor/@href}" class="">{$anchor/text()}</a>
  } </div>
  return $menudoc

};


declare function layout:page-footer($mode as xs:string) as node()
{
  let $footer :=
  <div id="footer" style="text-align: center; height: auto; padding: 10px 20px;">
    <a href="http://www.kb.dk/en/nb/dcm" title="DCM" 
    style="text-decoration:none;"><img 
    style="border: 0px; vertical-align:middle;" 
    alt="DCM Logo" 
    src="style/images/dcm_logo_small_white.png"
    id="dcm_logo"/><img 
    style="border: 0px; vertical-align:middle;" 
    alt="DCM Logo" 
    src="style/images/dcm_logo_small.png"
    id="dcm_logo_print"
    /></a>
    2014–2018 Danish Centre for Music Editing | Royal Danish Library | P.O. Box 2149 | Copenhagen K, Denmark | <a name="www.kb.dk" id="www.kb.dk" href="http://www.kb.dk/en/nb/dcm/">www.kb.dk/en/nb/dcm/</a> 
  </div>

  return $footer

};

