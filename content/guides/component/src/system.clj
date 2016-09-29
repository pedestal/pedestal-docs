                                                             ;; tag::ns[]
(ns system
  (:require [com.stuartsierra.component :as component]       ;; <1>
            [reloaded.repl :refer[init start stop go reset]] ;; <2>
            [io.pedestal.http :as http]                      ;; <3>
            [pedestal]                                       ;; <4>
            [routes]))                                       ;; <5>
                                                             ;; end::ns[]

                                                             ;; tag::app[]
(defn system
  [env]                                                      ;; <1>
  (component/system-map
   :service-map                                              ;; <2>
   {:env          env                                        ;; <3>
    ::http/routes routes/routes                              ;; <4>
    ::http/type   :jetty
    ::http/port   8890
    ::http/join?  false}

   :pedestal                                                 ;; <5>
   (component/using                                          ;; <6>
    (pedestal/new-pedestal)
    [:service-map])))
                                                             ;; end::app[]

                                                             ;; tag::init[]
(reloaded.repl/set-init! #(system :prod))                    ;; <1>
                                                             ;; end::init[]
