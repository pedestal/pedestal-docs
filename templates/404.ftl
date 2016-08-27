<#include "header.ftl">

  <div class="w-section clj-content-section">
    <div class="w-container">
      <h1>Page Not Found</h1>
      <p>We're sorry, that page could not be found on this site.</p>
      <div class="w-form">
        <form id="email-form" name="email-form" data-name="Email Form" action="https://www.google.com/search" method="get">
          <label for="q">Try searching for what you are looking for</label>
          <div class="w-row">
            <div class="w-col w-col-9">
              <input id="q" type="text" placeholder="Search clojure.org" name="q" data-name="q" required="required" class="w-input clj-404-search-input">
            </div>
            <div class="w-col w-col-3">
              <input type="submit" value="Search" data-wait="Please wait..." class="w-button clj-404-search-submit">
            </div>
          </div>
          <input id="as_sitesearch" type="hidden" name="as_sitesearch" data-name="as_sitesearch" value="clojure.org" class="w-input clj-search-as_sitesearch">
        </form>
        <div class="w-form-done">
          <p>Thank you! Your submission has been received!</p>
        </div>
        <div class="w-form-fail">
          <p>Oops! Something went wrong while submitting the form</p>
        </div>
      </div>
      <div>
        <h2>Other Options</h2>
      </div>
      <p>Visit our <a href="/index">home page</a> for an overview of what the site has to offer.</p>
      <h3>Browse By Category</h3>
      <ul>
        <li><a href="/overview/index">Overview</a>
        </li>
        <li><a href="/reference/index">Reference</a>
        </li>
        <li><a href="/api/index">API</a>
        </li>
        <li><a href="/guides/index">Guides</a>
        </li>
        <li><a href="/samples/index">Samples</a>
        </li>
        <li><a href="/community/resources">Community</a>
        </li>
      </ul>
    </div>
  </div>

<#include "footer.ftl">
