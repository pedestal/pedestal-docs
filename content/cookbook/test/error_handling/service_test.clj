(ns error-handling.service-test
  (:require [clojure.test :refer :all]
            [error-handling.service :as service]
            [io.pedestal.test :refer :all]
            [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [cheshire.core :as json]))

;; Create the service under test
(def service
  "Service under test"
  (::http/service-fn (http/create-servlet service/service)))

;; Create the test url generator
(def url-for
  "Test url generator."
  (route/url-for-routes (route/expand-routes service/routes)))

(deftest service-test
  (let [{:keys [status body]} (response-for service :get (url-for ::service/throwing-interceptor))]
    (is (= 500 status))
    (is (= "Exception caught!" body))))
