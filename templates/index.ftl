<#include "header.ftl">

  <div class="w-section clj-home-header">
    <div class="w-container">
      <div class="w-row">
        <div class="w-col w-col-8">
          <div class="clj-header-message">Pedestal is a <span class="clj-header-message-highlight">robust, practical, and fast</span> programming language with a set of useful features that together form a <span class="clj-header-message-highlight">simple, coherent, and powerful tool</span>.</div>
        </div>
        <div class="w-col w-col-4">
          <div class="clj-download-button-container"><a href="https://github.com/pedestal/pedestal" class="w-button clj-download-button">Get&nbsp;Pedestal</a>
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
<#include "footer.ftl">
