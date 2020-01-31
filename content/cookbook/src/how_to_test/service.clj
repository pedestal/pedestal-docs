(ns how-to-test.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]))

(defn handler1
  "A handler which returns a static response"
  [request]
  (ring-resp/response "pong"))

(defn handler2
  "A handler which returns a map of request params"
  [request]
  (ring-resp/response (merge (:params request)
                             (:path-params request))))

(defn handler3
  "A handler which echoes the POST'd JSON body."
  [request]
  (tap> request)
  (ring-resp/response (:json-params request)))

(def common-interceptors [(body-params/body-params) http/json-body])

(def routes #{["/h1" :get (conj common-interceptors `handler1)]
              ["/h2/:foo" :get (conj common-interceptors `handler2)]
              ["/h3" :post (conj common-interceptors `handler3)]})

(def service {:env                     :prod
              ::http/routes            routes
              ::http/resource-path     "/public"
              ::http/type              :jetty
              ::http/port              8080
              ::http/container-options {:h2c? true
                                        :h2?  false
                                        :ssl? false}})
