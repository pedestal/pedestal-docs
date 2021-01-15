<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Pedestal<#if (content.title)??> - <#escape x as x?xml>${content.title}</#escape></#if></title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="generator" content="Webflow">
  <link rel="stylesheet" type="text/css" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/normalize.css">
  <link rel="stylesheet" type="text/css" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/webflow.css">
  <link rel="stylesheet" type="text/css" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/clojureorg.webflow.css">
  <link rel="stylesheet" type="text/css" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/asciidoctor-mod.css">
  <script src="https://ajax.googleapis.com/ajax/libs/webfont/1.4.7/webfont.js"></script>
  <script>
    WebFont.load({
      google: {
        families: ["Open Sans:300,300italic,400,400italic,600,600italic","PT Serif:400,400italic,700,700italic","Source Code Pro:regular,500"]
      }
    });
  </script>
  <script type="text/javascript" src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/modernizr.js"></script>
  <script type="text/javascript" src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/anchor.min.js"</script>
  <link rel="shortcut icon" type="image/x-icon" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>images/pedestal-icon-32.png">
  <link rel="apple-touch-icon" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>images/pedestal-icon-256.png">
  <script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
  ga('create', 'UA-4857754-21', 'auto');
  ga('send', 'pageview');
  </script>
</head>
<body>
  <div data-collapse="none" data-animation="default" data-duration="400" data-contain="1" class="w-nav clj-navbar">
    <div class="w-container">
      <a href="/index" class="w-nav-brand w-clearfix clj-logo-container"><img width="60" src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>images/pedestal-glyph.png" class="clj-logo">
        <div class="clj-logo-text">Pedestal</div>
      </a>
      <nav role="navigation" class="w-nav-menu clj-nav-menu">
        <a href="/reference/index" class="w-nav-link clj-nav-link">Reference‍</a>
        <a href="/api/index" class="w-nav-link clj-nav-link">API</a>
        <a href="/guides/index" class="w-nav-link clj-nav-link">Guides</a>
        <a href="/cookbook/index" class="w-nav-link clj-nav-link">Cookbook</a> 
        <a href="/samples/index" class="w-nav-link clj-nav-link">Samples</a>
        <a href="/community/index" class="w-nav-link clj-nav-link">Community</a>
        <a href="#" data-ix="search-click-trigger" class="w-nav-link clj-nav-link clj-nav-search"></a>
      </nav>
      <div class="w-nav-button clj-menu-button">
        <div class="w-icon-nav-menu"></div>
      </div>
    </div>
  </div>
  <div data-ix="hide-search" class="w-section clj-search-section">
    <div class="w-container">
      <div class="w-form clj-search-form-wrapper">
        <form id="wf-form-Search-Form" name="wf-form-Search-Form" data-name="Search Form" action="/search" method="get">
          <div class="w-row">
            <div class="w-col w-col-9 w-col-small-9">
              <input id="q" type="text" placeholder="Search reference, guides, and API" name="q" data-name="q" autofocus="autofocus" class="w-input clj-search-input">
            </div>
            <div class="w-col w-col-3 w-col-small-3">
              <input type="submit" value="Search" data-wait="Please wait..." class="w-button clj-search-submit">
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
