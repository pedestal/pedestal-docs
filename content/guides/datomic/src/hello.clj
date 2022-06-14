;; tag::ns[]
(ns hello
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [ports.datomic.peer :as peer :refer [results]])) ;; <1>
;; end::ns[]

;; tag::response[]
(defn home-page
      [request]
      {:status 200  :body (str "Hello Colors! " (results))}) ;;<1>
;; end::response[]


;; tag::routing[]
(def routes
  (route/expand-routes                                   ;; <1>
    #{["/" :get home-page :route-name :greet]})) ;; <2>
;; end::routing[]

;; tag::server[]
(defn create-server []
      (http/create-server     ;; <1>
        {::http/routes routes  ;; <2>
         ::http/type   :jetty  ;; <3>
         ::http/port   8890})) ;; <4>

(defn start []
      (peer/init-db)
      (http/start (create-server))) ;; <5>
;; end::server[]
