;; tag::ns[]
(ns main
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]))
;; end::ns[]

;; tag::response_partials[]
(defn response [status body]
  {:status status :body body})

(def ok (partial response 200))
;; end::response_partials[]

;; tag::routes[]
(def echo
  {:name ::echo
   :enter (fn [context]
            (let [request (:request context)
                  response (ok context)]
              (assoc context :response response)))})

(def routes
  (route/expand-routes
   #{["/todo"                 :post   echo :route-name :list-create]
     ["/todo"                 :get    echo :route-name :list-query-form]
     ["/todo/:list-id"        :get    echo :route-name :list-view]
     ["/todo/:list-id"        :post   echo :route-name :list-item-create]
     ["/todo/:list-id/:item"  :get    echo :route-name :list-item-view]
     ["/todo/:list-id/:item"  :put    echo :route-name :list-item-update]
     ["/todo/:list-id/:item"  :delete echo :route-name :list-item-delete]}))
;; end::routes[]

;; tag::server[]
(def service-map
  {::http/routes routes
   ::http/type   :jetty
   ::http/port   8890})

(defn start []
  (http/start (http/create-server service-map)))

(defn start-dev []
  (http/start (http/create-server
               (assoc service-map
                      ::http/join? false))))
;; end::server[]
