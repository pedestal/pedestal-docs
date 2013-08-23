---
Title: Connecting 'Hello World' to Datomic
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

# Connecting "Hello World" to Datomic

This tutorial extends the [Hello World Service](/documentation/hello-world-service.md) to use
strings retrieved from an in-memory [Datomic] database. You can modify the tutorial files that
you created in the helloworld service, or copy the directory structure and start from the copy.


## Add Datomic to the Project

Edit `project.clj` and add the dependency on datomic;

```
(defproject helloworld "0.0.1-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [io.pedestal/pedestal.service "0.1.9"]

                 ;; Remove this line and uncomment the next line to
                 ;; use Tomcat instead of Jetty:
                 [io.pedestal/pedestal.jetty "0.1.9"]
                 ;; [io.pedestal/pedestal.tomcat "0.1.9"]

                 ;; auto-reload changes
                 [ns-tracker "0.2.1"]

                 ;; Logging
                 [ch.qos.logback/logback-classic "1.0.7" :exclusions [org.slf4j/slf4j-api]]
                 [org.slf4j/jul-to-slf4j "1.7.2"]
                 [org.slf4j/jcl-over-slf4j "1.7.2"]
                 [org.slf4j/log4j-over-slf4j "1.7.2"]

                 ;; Datomic - check clojars.org/com.datomoic/datomic-free
                 ;; and check for the latest version
                 [com.datomic/datomic-free "0.8.4020"]]
  :profiles {:dev {:source-paths ["dev"]}}
  :min-lein-version "2.0.0"
  :resource-paths ["config", "resources"]
  :aliases {"run-dev" ["trampoline" "run" "-m" "dev"]}
  :main ^{:skip-aot true} helloworld.server)
```

Run `lein deps` to fetch jar files needed by the added dependency.

## Write Schema and Seed Data

As described in the [Datomic tutorial] (http://docs.datomic.com/tutorial.html), a Datomic database consists
of facts, which in turn have attributes, which are defined by a schema. In a Pedestal app, a suitable place
to put schema files is the resources/[your-project-name-here] directory, so create the directory
(`mkdir -p resources/helloworld`) and place the Datomic schema definition below in a file named
`resources/helloworld/schema.edn`. This simple schema contains just one attribute:

```clj
[
  {:db/id #db/id[:db.part/db]
  :db/ident :hello/color
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/one
  :db/fulltext true
  :db/doc "Today's color"
  :db.install/_attribute :db.part/db}
]
```

In order to have something to show in a browser, we'll put some seed data into Datomic.
This file can also reside under the resources/helloworld directory. Create the file
`resources/helloworld/seed-data.edn` with the following contents:

```clj
[
  {:db/id #db/id[:db.part/user -1], :hello/color "True Mint"}
  {:db/id #db/id[:db.part/user -2], :hello/color "Yellowish White"}
  {:db/id #db/id[:db.part/user -3], :hello/color "Orange Red"}
  {:db/id #db/id[:db.part/user -4], :hello/color "Olive Green"}
]
```

The negative IDs indicate that Datomic should assign entity IDs automatically.

## Create Some Data Functions

Now we create functions to establish a connection to Datomic, define the schema, add
the seed data, and query for results. Create a file called `src/helloworld/peer.clj`
and add the following code:

```clj
(ns helloworld.peer
  (:require [datomic.api :as d :refer (q)]))

(def uri "datomic:mem://helloworld")

(def schema-tx (read-string (slurp "resources/helloworld/schema.edn")))
(def data-tx (read-string (slurp "resources/helloworld/seed-data.edn")))

(defn init-db []
  (when (d/create-database uri)
    (let [conn (d/connect uri)]
      @(d/transact conn schema-tx)
      @(d/transact conn data-tx))))

(defn results []
  (init-db)
  (let [conn (d/connect uri)]
   (q '[:find ?c :where [?e :hello/color ?c]] (d/db conn))))

```

# Use Database Results in the Service

Next, we need to use results from the database. For this, we will add
a function to `service.clj`. This new function will use `peer.clj` to
access data.

Open `src/helloworld/service.clj` and modify the `ns` macro to
reference the helloworld.peer namespace:

```clj
(ns helloworld.service
    (:require [io.pedestal.service.http :as bootstrap]
              [io.pedestal.service.http.route.definition :refer [defroutes]]
              [ring.util.response :refer [response]]
              [helloworld.peer :as peer :refer [results]]))
```

Let's now rewrite the `home-page` function in `service.clj` so that we
see the output from Datomic.

```clj
(defn home-page
  [request]
  (response (str "Hello Colors! " (results))))
```

If you still have the service running from
[Hello World Service](/documentation/hello-world-service/), then you
will need to exit the REPL. Restart the service the same way as
before: `lein repl`, `(use 'dev)`, and `(start)`.

Now point your browser at
[http://localhost:8080/](http://localhost:8080) and you will see the
thrilling string:

```clj
Hello Colors! [["True Mint"], ["Olive Green"], ["Orange Red"], ["Yellowish White"]]
```

Because `home-page` returns a string, the HTTP response will be sent
with a content type of "text/plain", as we can see by using "curl" to
access the server.

``` bash
$ curl -i http://localhost:8080/
HTTP/1.1 200 OK
Date: Fri, 22 Feb 2013 20:31:06 GMT
Content-Type: text/plain
Content-Length: 82
Server: Jetty(8.1.9.v20130131)

Hello Colors! [["True Mint"], ["Orange Red"], ["Olive Green"], ["Yellowish White"]]
```

# Where to go Next

For more about Datomic, check out [datomic.com][datomic].

[datomic]: http://www.datomic.com

