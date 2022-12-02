(ns front-page
  (:require [io.pedestal.http :as http]))

(defn respond-hello [_]
  {:status 200 :body "Hello, world!"})

(def routes
  #{["/greet" :get #'respond-hello]})

(defn start []
  (-> {::http/routes routes
       ::http/type   :jetty}
      http/create-server
      http/start))
