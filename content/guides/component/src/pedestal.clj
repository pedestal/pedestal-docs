;; tag::ns[]
(ns pedestal                                               ;; <1>
  (:require [com.stuartsierra.component :as component]     ;; <2>
            [io.pedestal.http :as http]))                  ;; <3>
;; end::ns[]

;; tag::component-init[]
(defrecord Pedestal [service-map                           ;; <1>
                     start-fn                              ;; <2>
                     stop-fn                               ;; <3>
                     service]                              ;; <4>
  component/Lifecycle                                      ;; <5>
;; end::component-init[]
;; tag::component-start[]
  (start [this]                                            ;; <1>
    (if service                                            ;; <2>
      this
      (-> service-map                                      ;; <3>
          (http/create-server)                             ;; <4>
          (start-fn)                                       ;; <5>
          ((partial assoc this :service)))))               ;; <6>
;; end::component-start[]

;; tag::component-stop[]
  (stop [this]                                             ;; <1>
    (when service                                          ;; <2>
      (stop-fn service))
    (assoc this :service nil)))                            ;; <3>
;; end::component-stop[]

;; tag::constructor[]
(defn new-pedestal
  [start-fn stop-fn]
  (map->Pedestal {:start-fn start-fn
                  :stop-fn  stop-fn}))
;; end::constructor[]
