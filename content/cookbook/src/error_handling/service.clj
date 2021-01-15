(ns error-handling.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.log :as log]
            [io.pedestal.interceptor :as interceptor]
            [io.pedestal.interceptor.chain :as chain]
            [io.pedestal.interceptor.error :as error]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]))

(def throwing-interceptor
  (interceptor/interceptor {:name ::throwing-interceptor
                            :enter (fn [ctx]
                                     ;; Simulated processing error
                                     (/ 1 0))
                            :error (fn [ctx ex]
                                     ;; Here's where you'd handle the exception
                                     ;; Remember to base your handling decision
                                     ;; on the ex-data of the exception.
                                     (let [{:keys [exception-type exception]} (ex-data ex)]
                                       ;; If you cannot handle the exception, re-attach it to the ctx
                                       ;; using the `:io.pedestal.interceptor.chain/error` key
                                       (assoc ctx ::chain/error ex)))}))

(def service-error-handler
  (error/error-dispatch [ctx ex]
                        ;; Handle `ArithmeticException`s thrown by `::throwing-interceptor`
                        [{:exception-type :java.lang.ArithmeticException :interceptor ::throwing-interceptor}]
                        (assoc ctx :response {:status 500 :body "Exception caught!"})

                        :else (assoc ctx ::chain/error ex)))

(def common-interceptors [service-error-handler (body-params/body-params) http/html-body])

(def routes #{["/" :get (conj common-interceptors throwing-interceptor)]})

(def service {:env                     :prod
              ::http/routes            routes
              ::http/resource-path     "/public"
              ::http/type              :jetty
              ::http/port              8080
              ::http/container-options {:h2c? true
                                        :h2?  false
                                        :ssl? false}})
