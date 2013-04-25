---
Title: Hello World Service
---

<!--
 Copyright 2013 Relevance, Inc.

 The use and distribution terms for this software are covered by the
 Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0)
 which can be found in the file epl-v10.html at the root of this distribution.

 By using this software in any fashion, you are agreeing to be bound by
 the terms of this license.

 You must not remove this notice, or any other, from this software.
-->

# Hello World Service

This explains how to create a simple "Hello World" service on
Pedestal. This is the simplest ever service. As you can easily guess,
the service just responds with "Hello, World!" whenever you need a
friendly greeting.

## Create a Clojure project for the server side

```
mkdir ~/tmp
cd ~/tmp
lein new pedestal-service helloworld
cd helloworld
```

## Edit project.clj

The generated project definition looks like this:

```clojure
(defproject helloworld "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.0"]
                 [io.pedestal/pedestal.service "0.1.0"]

                 ;; Remove this line and uncomment the next line to
                 ;; use Tomcat instead of Jetty:
                 [io.pedestal/pedestal.jetty "0.1.0"]
                 ;; [io.pedestal/pedestal.tomcat "0.1.0"]

                 ;; Logging
                 [ch.qos.logback/logback-classic "1.0.7"]
                 [org.slf4j/jul-to-slf4j "1.7.2"]
                 [org.slf4j/jcl-over-slf4j "1.7.2"]
                 [org.slf4j/log4j-over-slf4j "1.7.2"]]
  :profiles {:dev {:source-paths ["dev"]}}
  :resource-paths ["config"]
  :main ^{:skip-aot true} helloworld.server)
```

You may want to change the description, add dependencies, change the
license, or whatever else you'd normally do to project.clj. Once you
finish editing the file, run `lein deps` to fetch any jars you need.

## Edit service.clj

Our project name is helloworld, so the template generated two files
under `src/helloworld`. `service.clj` defines the logic of our 
service. `server.clj` creates a server (a daemon) to host that
service.

Of course, if you used a different project name, your service.clj
would be src/your-project-name-here/service.clj. Also, the namespace
will be your-project-name-here.service instead of `helloworld.service`.

The default service.clj demonstrates a few things, but for now let's
replace the default service.clj with the smallest example that will
work. Edit src/helloworld/service.clj until it looks like this:

```clojure
(ns helloworld.service
    (:require [io.pedestal.service.http :as bootstrap]
              [io.pedestal.service.http.route.definition :refer [defroutes]]
              [ring.util.response :refer [response]]))

(defn home-page
  [request]
  (response "Hello World!"))

(defroutes routes
  [[["/" {:get home-page}]]])

;; Consumed by helloworld.server/create-server
(def service {:env :prod
              ::bootstrap/routes routes
              ::bootstrap/type :jetty
              ::bootstrap/port 8080})
```

The `home-page` function defines the simplest HTTP response to the
browser. In `routes`, we map the URL `/` so it will invoke
`home-page`. Finally, the function `service` describes how to hook
this up to a server. Notice that this just returns a map. `service`
doesn't actually start the server up; it defines how the service will
look when it gets started later.

There's nothing magic about these function names. There are no
required names here. One of our design principles in Pedestal is that
all the connections between parts of your application should be
_evident_. You should be able to trace functions from call to
definition without any "magic" or "action at a distance"
metaprogramming.

Take a peek into `src/helloworld/server.clj`. We won't be changing it,
but it's interesting to look at the create-server function:

``` clojure
(ns helloworld.server
  (:require [helloworld.service :as service]
            [io.pedestal.service.http :as bootstrap]))

;; ...

(defn create-server
  "Standalone dev/prod mode."
  [& [opts]]
  (alter-var-root #'service-instance
                  (constantly (bootstrap/create-server (merge service/service opts)))))

;; ...

```

You can see that `create-server` calls `helloworld.service/service` to
get that map we just looked at. `create-server` merges that map with
any per-invocation options, and then creates the actual server by
calling `bootstrap/create-server`.

## Run it in Dev Mode

We'll start the server from a repl, which is how we will normally run in development mode.

```
$ lein repl

nREPL server started on port 52471
REPL-y 0.1.6
Clojure 1.5.0
    Exit: Control+D or (exit) or (quit)
Commands: (user/help)
    Docs: (doc function-name-here)
          (find-doc "part-of-name-here")
  Source: (source function-name-here)
          (user/sourcery function-name-here)
 Javadoc: (javadoc java-object-or-class-here)
Examples from clojuredocs.org: [clojuredocs or cdoc]
          (user/clojuredocs name-here)
          (user/clojuredocs "ns-here" "name-here")
```

To make life easier in the repl, pedestal generated a "dev.clj" file with some convenience functions. We'll use one to start the server:

```clojure
helloworld.server=> (use 'dev)
nil
helloworld.server=> (start)
nil

```

Now let's see "Hello World!"

Go to [http://localhost:8080/](http://localhost:8080/)  and you'll see a shiny "Hello World!" in your browser.

Done! Let's stop the server.

```
helloworld.server=> (stop)
nil
```

## Where To Go Next

For more about building out the server side, you can look at
[Routing and Linking](/documentation/service-routing/) or
[Connecting to Datomic](/documentation/connecting-to-datomic/).

