<#include "header.ftl">

<div class="w-section clj-content-section">
  <div class="w-container">
    <div class="clj-section-nav-container">
      <div data-collapse="small" data-animation="default" data-duration="200" data-contain="1" class="w-nav clj-section-navbar">
        <div class="w-container">
          <nav role="navigation" class="w-nav-menu clj-section-nav-menu">
            <#list posts as post>
              <#if (post.status == "published")>
                <a href="/${post.uri}" class="w-nav-link clj-section-nav-item-link"><#escape x as x?xml>${post.title}</#escape></a>
              </#if>
      </#list>
          </nav>
          <div data-ix="toggle-section-nav-icon" class="w-nav-button w-clearfix clj-section-nav-toggle">
            <div class="clj-section-nav-text"><#if (content.navlinktext)??>${content.navlinktext}<#else>${content.title}</#if></div>
            <div class="clj-section-nav-icon-closed"></div>
            <div data-ix="init-hide-section-nav-icon-open" class="clj-section-nav-icon-open"></div>
          </div>
        </div>
      </div>
    </div>

    <div class="clj-content-container">
      <h1>${content.title}</h1>
      <p><em>${content.date?string("dd MMMM yyyy")}</em><br/>
         <em>${content.author}</em></p>

      ${content.body}
    </div>
  </div>
</div>

<#include "footer.ftl">
