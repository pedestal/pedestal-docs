(ns logging.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [io.pedestal.interceptor :refer [interceptor]]
            [io.pedestal.log :as log]
            [ring.util.response :as ring-resp]))

(def log-request
  "Logs all http requests with response time."
  {:name ::log-request
   :enter (fn [context]
              (assoc-in context [:request :start-time] (System/currentTimeMillis)))
   :leave (fn [context]
              (let [{:keys [uri start-time request-method]} (:request context)
                    finish (System/currentTimeMillis)
                    total (- finish start-time)]
                   (log/info :msg "request completed"
                             :method (clojure.string/upper-case (name request-method))
                             :uri uri
                             :status (:status (:response context))
                             :response-time total)))})

(defn home-page
  [request]
  (ring-resp/response "Hello World!"))

(def routes #{["/" :get `home-page]})

(def service {::http/routes            routes
              ::http/request-logger    (interceptor log-request)
              ::http/type              :jetty
              ::http/port              8080})