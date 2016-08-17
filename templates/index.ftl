<#include "header.ftl">

  <div class="w-section clj-home-header">
    <div class="w-container">
      <div class="w-row">
        <div class="w-col w-col-8">
          <div class="clj-header-message">Pedestal is a <span class="clj-header-message-highlight">robust, practical, and fast</span> programming language with a set of useful features that together form a <span class="clj-header-message-highlight">simple, coherent, and powerful tool</span>.</div>
        </div>
        <div class="w-col w-col-4">
          <div class="clj-download-button-container"><a href="http://repo1.maven.org/maven2/org/clojure/clojure/1.7.0/clojure-1.7.0.zip" class="w-button clj-download-button">Download&nbsp;Clojure 1.7.0</a>
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
              <h2>The Clojure Programming Language</h2>
              <p>Clojure is a dynamic, general-purpose programming language, combining the approachability and interactive development of a scripting language with an efficient and robust infrastructure for multithreaded programming. Clojure is a compiled language, yet remains completely dynamic – every feature supported by Clojure is supported at runtime. Clojure provides easy access to the Java frameworks, with optional type hints and type inference, to ensure that calls to Java can avoid reflection.</p>
              <p>Clojure is a dialect of Lisp, and shares with Lisp the code-as-data philosophy and a powerful macro system. Clojure is predominantly a functional programming language, and features a rich set of immutable, persistent data structures. When mutable state is needed, Clojure offers a software transactional memory system and reactive Agent system that ensure clean, correct, multithreaded designs.</p>
              <p>I hope you find Clojure's combination of facilities elegant, powerful, practical and fun to use.</p>
              <p>Rich Hickey
                <br>author of Clojure and CTO Cognitect</p>
            </div>
          </div>
        </div>
        <div class="w-col w-col-4">
          <div class="clj-learn-more">
            <h3 class="clj-learn-more-heading">Learn More</h3><a href="about/rationale" class="w-inline-block clj-learn-more-item"><h4 class="clj-learn-more-item-heading">Rationale</h4><p class="clj-learn-more-detail">A brief overview of Clojure and the features it includes</p></a><a href="guides/getting_started" class="w-inline-block clj-learn-more-item"><h4 class="clj-learn-more-item-heading">Getting Started</h4><p class="clj-learn-more-detail">Resources for getting Clojure up and running</p></a><a href="reference/documentation" class="w-inline-block clj-learn-more-item"><h4 class="clj-learn-more-item-heading">Reference</h4><p class="clj-learn-more-detail">Grand tour of all that Clojure has to offer</p></a><a href="guides/guides" class="w-inline-block clj-learn-more-item"><h4 class="clj-learn-more-item-heading">Guides</h4><p class="clj-learn-more-detail">Walkthroughs to help you learn along the way</p></a><a href="community/resources" class="w-inline-block clj-learn-more-item"><h4 class="clj-learn-more-item-heading">Community</h4><p class="clj-learn-more-detail">We have a vibrant, flourishing  community. Join us on our Google Group, find us on IRC in #clojure, or join our Slack channel.</p></a>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="w-section clj-home-features-section">
    <div class="w-container">
      <div class="clj-home-features-intro">
        <h3>Features</h3>
        <p>Clojure has a set of useful features that together form a simple, coherent, and powerful tool.</p>
      </div>
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Dynamic Development</h4>
            <p>Clojure is a dynamic environment you can interact with. Almost all of the language constructs are reified, and thus can be examined and changed. You can grow your program, with data loaded, adding features, fixing bugs, testing, in an unbroken stream.</p>
          </div>
        </div>
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Functional Programming</h4>
            <p>Clojure provides the tools to avoid mutable state, provides functions as first-class objects, and emphasizes recursive iteration instead of side-effect based looping. Clojure is impure, yet stands behind the philosophy that programs that are more functional are more robust.</p>
          </div>
        </div>
      </div>
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>LISP</h4>
            <p>Clojure is a member of the Lisp family of languages. Many of the features of Lisp have made it into other languages, but Lisp's approach to code-as-data and its macro system still set it apart. Additionally, Clojure’s maps, sets, and vectors are as first class in Clojure as lists are in Lisp.</p>
          </div>
        </div>
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Runtime Polymorphism</h4>
            <p>Systems that utilize runtime polymorphism are easier to change and extend. Clojure offers simple, powerful and flexible mechanisms for runtime polymorphism. Clojure’s protocols and datatypes features add mechanisms for abstraction and data structure definition with no compromises vs the facilities of the host platform.</p>
          </div>
        </div>
      </div>
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Concurrent Programming</h4>
            <p>Clojure simplifies multi-threaded programming in several ways. Because the core data structures are immutable, they can be shared readily between threads. Clojure, being a practical language, allows state to change but provides mechanism to ensure that, when it does so, it remains consistent, while alleviating developers from having to avoid conflicts manually using locks etc.</p>
          </div>
        </div>
        <div class="w-col w-col-6">
          <div class="clj-home-feature-item">
            <h4>Hosted on the JVM</h4>
            <p>Clojure is designed to be a hosted language, sharing the JVM type system, GC, threads etc. All functions are compiled to JVM bytecode. Clojure is a great Java library consumer, offering the dot-target-member notation for calls to Java. Clojure supports the dynamic implementation of Java interfaces and classes.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="w-section clj-home-updates-section">
    <div class="w-container">
      <div class="w-row">
        <div class="w-col w-col-6">
          <div class="clj-home-updates-container">
            <h3>News</h3>
            <#assign c = 0>
            <ul class="w-list-unstyled clj-home-updates-list">
              <#list posts as post>
                <#if (post.status == "published")>
                  <li><span class="clj-home-updates-date">${post.date?string("yyyy-MM-dd")}</span>
                      &nbsp;<a href="/${post.uri}" class="clj-home-updates-link"><#escape x as x?xml>${post.title}</#escape></a></li>
                  <#assign c = c + 1>
                  <#if (c >= 3)>
                    <#break>
                  </#if>
                </#if>
              </#list>
            </ul>
          </div>
        </div>
        <div class="w-col w-col-6">
          <div class="clj-home-updates-container">
            <h3>Upcoming Events</h3>
              <#assign c = 0>
              <ul class="w-list-unstyled clj-home-updates-list">
              <#list events?reverse as event>
                <#assign endtime = (event.end + " 23:59:00")?datetime("yyyy-MM-dd hh:mm:ss")>
                <#if (event.status == "published" && endtime >= .now)>
                  <li><span class="clj-home-updates-date">${endtime?string("yyyy-MM-dd")}</span>
                      &nbsp;<a href="/${event.uri}" class="clj-home-updates-link"><#escape x as x?xml>${event.title} ${event.edition}</#escape></a></li>
                  <#assign c = c + 1>
                  <#if (c >= 3)>
                    <#break>
                  </#if>
                </#if>
              </#list>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="w-section clj-home-support">
    <div class="w-container">
      <div class="w-row">
        <div class="w-col w-col-8">
          <div>
            <h3>Support</h3>
            <p>Cognitect, the maintainers of Clojure, offers enterprise-level support for Clojure. Wherever you are in Clojure Platform adoption – whether you are getting your feet wet with Clojure or are ready to push finished applications into production – you can lean on Cognitect for 24x7 support.</p>
            <p>Cognitect offers developer support, production support, and architectural review services for companies and teams deploying Clojure and ClojureScript.</p>
          </div>
        </div>
        <div class="w-col w-col-4">
          <blockquote class="clj-home-support-quote">“We have created some of the sharpest tools in the business. We believe this platform is a better way to develop software, and we want you to have confidence using and deploying these tools. Open source doesn't mean you're on your own any more.” – cognitect.com</blockquote>
        </div>
      </div>
    </div>
  </div>
  <div class="w-section clj-home-companies-section">
    <div class="w-container">
      <div>
        <h3 class="clj-home-companies-heading">Companies Succeeding with Clojure</h3>
      </div>
      <div class="w-row">
        <div class="w-col w-col-4">
          <div class="clj-home-company clj-home-company-walmart">
            <blockquote class="clj-home-company-quote">“Our Clojure system just handled its first Walmart black Friday and came out without a scratch.”</blockquote>
            <div class="clj-home-company-attribution">Anthony Marcar, Senior Architect
              <br>Walmart Labs</div>
          </div>
        </div>
        <div class="w-col w-col-4">
          <div class="clj-home-company clj-home-company-puppet">
            <blockquote class="clj-home-company-quote">“Clojure is a functional programming language from top to bottom. This means that code written in Clojure is very modular, composable, reusable and easy to reason about.”</blockquote>
            <div class="clj-home-company-attribution">Chris Price, Software Engineer
              <br>Puppet Labs</div>
          </div>
        </div>
        <div class="w-col w-col-4">
          <div class="clj-home-company clj-home-company-thoughtworks">
            <blockquote class="clj-home-company-quote">“We discussed the existing Clojure community, the maturity of the language itself and the momentum we saw in the industry. Companies are seeing speed to market deliveries ... based on Clojure.”</blockquote>
            <div class="clj-home-company-attribution">Dave Elliman, Head of Technology
              <br>ThoughtWorks</div>
          </div>
        </div>
      </div>
    </div>
  </div>
<#include "footer.ftl">
