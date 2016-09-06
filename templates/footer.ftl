  <div class="w-section clj-footer">
    <div class="w-container clj-footer-legal-container">
      <div class="w-clearfix clj-footer-legal">
        <div class="clj-footer-legal-links">
          <div class="clj-footer-copyright">Copyright 2013-2016 <a class="clj-footer-sub-link" href="https://www.cognitect.com">Cognitect, Inc.</a> | <a class="clj-footer-sub-link" href="/privacy">Privacy Policy</a><br/>Published ${published_date?string("yyyy-MM-dd")}
          </div>
          <div class="clj-footer-designed-by">Site design by <a class="clj-footer-sub-link" href="http://tomhickey.com/">Tom Hickey</a>
          </div>
        </div>
      </div>
    </div>
  </div>
  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script type="text/javascript" src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/webflow.js"></script>
  <script type="text/javascript" src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/highlight.pack.js"></script>
  <script>hljs.initHighlightingOnLoad();</script>
  <!--[if lte IE 9]><script src="https://cdnjs.cloudflare.com/ajax/libs/placeholders/3.0.2/placeholders.min.js"></script><![endif]-->
</body>
</html>
