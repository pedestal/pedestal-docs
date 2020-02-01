(ns static-resource.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]))

(defn home-page
  [request]
  (ring-resp/response "Hello World!"))

(def common-interceptors [(body-params/body-params) http/html-body])

(def routes #{["/" :get (conj common-interceptors `home-page)]})

(def service {:env                     :prod
              ::http/routes            routes
              ;; Resources will be served from the resource directory's `public`
              ;; sub directory.
              ::http/resource-path     "/public"
              ::http/type              :jetty
              ::http/port              8080
              ::http/container-options {:h2c? true
                                        :h2?  false
                                        :ssl? false}})
