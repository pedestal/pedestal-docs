(ns intc.service
  (:require [io.pedestal.http :as http]))

                              ;; tag::hello[]
(def say-hello
  {:name ::say-hello
   :enter (fn [context]
            (assoc context :response {:body "Hello, world!"
                                      :status 200}))})
                              ;; end::hello[]

(def routes
  #{}) ;; <1>

(def routes
  #{["/hello" :get say-hello]})

(defn start
  []
  (-> {::http/port   8822     ;; <2>
       ::http/join?  false    ;; <3>
       ::http/type   :jetty   ;; <4>
       ::http/routes routes}  ;; <5>
      http/create-server      ;; <6>
      http/start))            ;; <7>
