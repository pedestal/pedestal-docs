(ns intc.service
  (:require [io.pedestal.http :as http]
            [io.pedestal.interceptor.chain :as chain]
            [io.pedestal.interceptor.error :as err]))

                              ;; tag::hello[]
(def say-hello
  {:name ::say-hello
   :enter (fn [context]
            (assoc context :response {:body "Hello, world!"
                                      :status 200}))})
                              ;; end::hello[]


                              ;; tag::new_players[]
(def odds
  {:name ::odds
   :enter (fn [context]
            (assoc context :response {:body "I handle odd numbers\n"
                                      :status 200}))})

(def evens
  {:name ::evens
   :enter (fn [context]
            (assoc context :response {:body "Even numbers are my bag\n"
                                      :status 200}))})
                              ;; end::new_players[]


                              ;; tag::chooser[]
(def chooser
  {:name  ::chooser
   :enter (fn [context]
            (try
              (let [param (get-in context [:request :query-params :n]) ; <1>
                    n     (Integer/parseInt param)               ;
                    nxt   (if (even? n) evens odds)]             ;
                (chain/enqueue context [nxt]))                   ; <2>
              (catch NumberFormatException e                     ;
                (assoc context :response {:body   "Not a number!\n" ; <3>
                                          :status 400}))))})

(def routes
  #{["/hello"        :get say-hello]
    ["/data-science" :get chooser]})
                              ;; end::chooser[]

                              ;; tag::chooser2[]
(def chooser2
  {:name  ::chooser
   :enter (fn [context]
            (let [n (-> context :request :query-params :n Integer/parseInt)
                  nxt (if (even? n) evens odds)]
              (chain/enqueue context [nxt])))})

(def routes
  #{["/hello"        :get say-hello]
    ["/data-science" :get chooser2]})
                              ;; end::chooser2[]

                              ;; tag::error-i[]
(def number-format-handler
  {:name ::number-format-handler
   :error (fn [context exc]
            (if (= :java.lang.NumberFormatException (:exception-type (ex-data exc)))    ; <1>
                (assoc context :response {:body   "Not a number!\n" :status 400})   ; <2>
                (assoc context :io.pedestal.interceptor.chain/error exc)))}) ; <3>

(def routes
  #{["/hello"        :get say-hello]
    ["/data-science" :get [number-format-handler chooser2]]})

;; end::error-i[]

;; tag::error-dispatch[]
(def errors
  (err/error-dispatch [ctx ex]

   [{:exception-type :java.lang.NumberFormatException}]                ;<1>
   (assoc ctx :response {:status 400 :body "Not a number!\n"})))       ;<2>

(def routes
  #{["/hello"        :get say-hello]
    ["/data-science" :get [errors chooser2]]})
;; end::error-dispatch[]

(defn start
  []
  (-> {::http/port   8822     ;; <2>
       ::http/join?  false    ;; <3>
       ::http/type   :jetty   ;; <4>
       ::http/routes routes}  ;; <5>
      http/create-server      ;; <6>
      http/start))            ;; <7>
