<#include "header.ftl">

<script>
  (function() {
    var cx = '004438906124835441594:8ruebryjydg';
    var gcse = document.createElement('script');
    gcse.type = 'text/javascript';
    gcse.async = true;
    gcse.src = 'https://cse.google.com/cse.js?cx=' + cx;
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(gcse, s);
  })();
</script>

<div class="w-section clj-content-section">
  <div class="w-container">

    <h1>${content.title}</h1>

    ${content.body}

    <div class="clj-search-results">
      <gcse:searchresults-only linkTarget="" enableOrderBy="false"></gcse:searchresults-only>
    </div>
  </div>
</div>

<#include "footer.ftl">
