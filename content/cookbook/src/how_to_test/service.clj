(ns how-to-test.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]
            [io.pedestal.http.ring-middlewares :as middlewares]))

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
  (ring-resp/response (:json-params request)))

(defn handler4
  "A handler which echoes the POST'd JSON body."
  [request]
  (-> (ring-resp/response (:multipart-params request))
      (ring-resp/status 201)))

(def common-interceptors [(body-params/body-params) http/json-body])

(defn- string-store [item]
  (tap> {:item item})
  (-> (select-keys item [:filename :content-type])
      (assoc :content (slurp (:stream item)))))

(def routes #{["/h1" :get (conj common-interceptors `handler1)]
              ["/h2/:foo" :get (conj common-interceptors `handler2)]
              ["/h3" :post (conj common-interceptors `handler3)]
              ["/h4" :post (into common-interceptors [(middlewares/multipart-params {:store string-store}) `handler4])]})

(def service {:env                     :prod
              ::http/routes            routes
              ::http/resource-path     "/public"
              ::http/type              :jetty
              ::http/port              8080
              ::http/container-options {:h2c? true
                                        :h2?  false
                                        :ssl? false}})
