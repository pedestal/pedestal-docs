(ns verb-neutral-routes.service-test
  (:require [clojure.test :refer :all]
            [verb-neutral-routes.service :as service]
            [io.pedestal.test :refer :all]
            [io.pedestal.http :as http]))

;; Create the service under test
(def service
  "Service under test"
  (::http/service-fn (http/create-servlet service/service)))

(deftest service-test
  (is (= "Hello World!"
         (:body (response-for service :get "/"))))
  (binding [service/*hit-count* (atom 42)]
    (is (= "{\"count\":42}"
           (:body (response-for service :stats "/")))))
  (is (= "{\"version\":1.0}"
         (:body (response-for service :version "/")))))
