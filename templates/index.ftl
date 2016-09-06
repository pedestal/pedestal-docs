<#include "header.ftl">

  <div class="w-section clj-home-header">
    <div class="w-container">
      <div class="w-row">
        <div class="w-col w-col-8">
          <div class="clj-header-message">Pedestal is a <span class="clj-header-message-highlight">sturdy and reliable</span> base for <span class="clj-header-message-highlight">services and APIs</span>.</div>
        </div>
        <div class="w-col w-col-4">
          <div class="clj-download-button-container"><a href="https://github.com/pedestal/pedestal#getting-the-latest-release" class="w-button clj-download-button">Get&nbsp;Pedestal</a>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="w-section clj-home-intro-section">
    <div class="w-container">
      <div class="w-row">
        <div class="w-col w-col-8">
          <div>
            <div class="clj-intro-message">
              <h2>What is Pedestal?</h2>
              <p>
                Pedestal is a set of libraries that we use to build
                services and applications. It runs in the back end and
                can serve up whole HTML pages or handle API requests.
              </p>
              <p>
                There are a lot of tools in that space, so why did we
                build Pedestal?  We had two main reasons:
              </p>
              <ul>
                <li>
                  <b>Pedestal is designed for APIs first.</b> Most web
                  app frameworks still focus on the "page model" and
                  server side rendering. Pedestal lets you start
                  simple and add that if you need it.
                </li>
                <li>
                  <b>Pedestal makes is easy to create "live"
                  applications.</b> Applications must respond with
                  immediate feedback even while some back-end
                  communication goes on. Pedestal makes it easy to
                  deliver server-sent events and asynchronous updates.
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div class="w-col w-col-4">
          <div>
            <h2><img src="/images/animated-front-page-sample.gif" alt="code sample"/></h2>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="w-section clj-home-features-section">
    <div class="w-container">
      <div class="clj-home-features-intro">
        <h3>Features</h3>
      </div>
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Ready for Production</h4>
            <p>Pedestal works with a huge variety of containers and deployment options. Deploy applications or microservices on unikernels, Docker containers, or JAR files. Pedestal supports Tomcat, Jetty, Immutant (with Undertow), Vert.x, nginx, and Netty.</p>
          </div>
        </div>
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Secure by Default</h4>
            <p>Pedestal automatically uses secure headers, CSRF-protection, and other best practices. It works with CORS to allow secure front end applications.</p>
          </div>
        </div>
      </div>
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Dynamic on the Front End...</h4>
            <p>Pedestal lets you create dynamic applications with server-sent events and websockets. It uses Clojure's async capabilities and Java NIO.</p>
          </div>
        </div>
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>...And on the Back End</h4>
            <p>Routers and Interceptors let Pedestal services apply different behavior based on each incoming request, rather than statically wrapping everything up during initialization.</p>
          </div>
        </div>
      </div>
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Composable</h4>
            <p>Pedestal is built from pieces that connect via protocols, giving you the flexibility to swap out any part.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
<#include "footer.ftl">
