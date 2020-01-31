(ns error-handling.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.interceptor :as interceptor]
            [io.pedestal.log :as log]
            [io.pedestal.interceptor.error :as error]
            [io.pedestal.http.route :as route]
            [io.pedestal.http.body-params :as body-params]
            [ring.util.response :as ring-resp]))

(def throwing-interceptor
  (interceptor/interceptor {:name ::throwing-interceptor
                            :enter (fn [ctx]
                                     (/ 1 0))
                            :error (fn [ctx ex]
                                     ;; Here's where you'd handle the exception
                                     ;; If you cannot handle the exception, throw it so that
                                     ;; other interceptors have the opportunity to handle it.
                                     (throw ex))}))

(def service-error-handler
  (error/error-dispatch [ctx ex]
                        [{:exception-type :java.lang.ArithmeticException :interceptor ::throwing-interceptor}]
                        (assoc ctx :response {:status 500 :body "Exception caught!"})

                        :else (throw ex)))

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
