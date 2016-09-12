                                                                    ;; tag::ns[]
(ns system
  (:require [com.stuartsierra.component :as component]              ;; <1>
            [reloaded.repl :refer[system init start stop go reset]] ;; <2>
            [io.pedestal.http :as http]                             ;; <3>
            [pedestal]                                              ;; <4>
            [routes]))                                              ;; <5>
                                                                    ;; end::ns[]

                                                                    ;; tag::app[]
(defn app                                                           ;; <1>
  ([]
   (app :pedestal-start-fn http/start :pedestal-stop-fn http/stop))
  ([& opts]
   (let [{:keys [pedestal-start-fn
                 pedestal-stop-fn]} (apply hash-map opts)]
     (component/system-map
      :service-map                                                  ;; <2>
      {::http/routes routes/routes                                  ;; <3>
       ::http/type   :jetty
       ::http/port   8890
       ::http/join?  false}

      :pedestal                                                     ;; <4>
      (component/using
       (pedestal/new-pedestal pedestal-start-fn pedestal-stop-fn)   ;; <5>
       [:service-map])))))                                          ;; <6>
                                                                    ;; end::app[]

                                                                    ;; tag::init[]
(reloaded.repl/set-init! app)                                       ;; <1>
                                                                    ;; end::init[]
