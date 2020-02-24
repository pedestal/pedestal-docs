(ns how-to-test.service-test
  (:require [clojure.test :refer :all]
            [how-to-test.service :as service]
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
  ;; test GET'ing a simple response body
  (is (= 200
         ;; Use the route name with `url-for` to generate the url
         (:status (response-for service :get (url-for ::service/handler1)))))
  ;; test GET with path and query params
  (is (= 200
         (:status (response-for service :get (url-for ::service/handler2                                                        
                                                      :path-params {:foo "bar"}
                                                      :query-params {:sort "ASC"})))))
  ;; test POST'ing JSON
  (is (= 200
         (:status (response-for service
                                :post (url-for ::service/handler3)
                                ;; Set the `Content-Type` so `body-params`
                                ;; can parse the body
                                :headers {"Content-Type" "application/json"}
                                ;; Encode the payload
                                :body (json/encode {:foo "bar"})))))

  ;; testing File upload
  ;; We'll create a form body which simulates uploading two files.
  ;; NOTE: Consider using a test-friendly store during your testing.
  ;; See https://github.com/pedestal/pedestal/blob/master/service/test/io/pedestal/http/ring_middlewares_test.clj#L107-L129 for an example.
  (let [form-body (str "--XXXX\r\n"
                       "Content-Disposition: form-data; name=\"file1\"; filename=\"foobar1.txt\"\r\n\r\n"
                       "bar\r\n"
                       "--XXXX\r\n"
                       "Content-Disposition: form-data; name=\"file2\"; filename=\"foobar2.txt\"\r\n\r\n"
                       "baz\r\n"
                       "--XXXX--")
        {:keys [status]} (response-for service
                                       :post (url-for ::service/handler4)
                                       :body form-body
                                       :headers {"Content-Type" "multipart/form-data; boundary=XXXX"})]
    ;; testing file processing
    (is (= 201 status))))
