(ns verb-neutral-routes.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]
            [io.pedestal.http.ring-middlewares :as middlewares]))

(def ^:dynamic *hit-count* (atom 0))

(defn home-page
  [_]
  (swap! *hit-count* inc)
  (ring-resp/response "Hello World!"))

(defn stats
  "A handler for the :stats custom method."
  [_]
  (ring-resp/response {:count @*hit-count*}))

(defn version
  "A mock handler for the :version custom method."
  [_]
  (ring-resp/response {:version 1.0}))

(def common-interceptors [(body-params/body-params) http/json-body])

;; tag::routes[]
(def routes #{;; If a map of :verbs is provided, it
              ;; replaces the set of default verbs
              {:verbs #{:get :stats :version}}
              ["/" :get (conj common-interceptors `home-page)]
              ["/" :stats (conj common-interceptors `stats)]
              ["/" :version (conj common-interceptors `version)]})
;; end::routes[]

(def service {:env                     :prod
              ::http/routes            routes
              ::http/resource-path     "/public"
              ::http/type              :jetty
              ::http/port              8080
              ::http/container-options {:h2c? true
                                        :h2?  false
                                        :ssl? false}})
