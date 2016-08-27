<#include "header.ftl">

<div class="w-section clj-content-section">
  <div class="w-container">

    <#if content.section??>
      <div class="clj-section-nav-container">
          <div data-collapse="small" data-animation="default" data-duration="200" data-contain="1" class="w-nav clj-section-navbar">
            <div class="w-container">
              <nav role="navigation" class="w-nav-menu clj-section-nav-menu">

                <#include "nav/" + content.section + ".ftl">

              </nav>
              <div data-ix="toggle-section-nav-icon" class="w-nav-button w-clearfix clj-section-nav-toggle">
                <div class="clj-section-nav-text"><#if (content.navlinktext)??>${content.navlinktext}<#else>${content.title}</#if></div>
                <div class="clj-section-nav-icon-closed"></div>
                <div data-ix="init-hide-section-nav-icon-open" class="clj-section-nav-icon-open"></div>
              </div>
            </div>
          </div>
        </div>
    </#if>

    <div class="clj-content-container">

        <h1>${content.title}</h1>

        ${content.body}

    </div>
  </div>
</div>

<#include "footer.ftl">
