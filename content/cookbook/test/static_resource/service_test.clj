(ns static-resource.service-test
  (:require [clojure.test :refer :all]
            [static-resource.service :as service]
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
  (let [{:keys [status body]} (response-for service :get (url-for ::service/home-page))]
    (is (= 200 status))
    (is (= "Hello World!" body)))
  (is (= 200 (:status (response-for service :get "/foo.txt")))))

(comment

 (def s (-> service/service
            (assoc ::http/join? false)
            http/create-server
            http/start))

 (http/stop s)
 )
