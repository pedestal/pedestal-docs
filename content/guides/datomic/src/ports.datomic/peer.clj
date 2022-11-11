(ns ports.datomic.peer
  (:require [datomic.api :as d :refer (q)]
            [io.pedestal.log :as log]))

(def uri "datomic:dev://localhost:4334/hello")

(def schema-tx (read-string (slurp "resources/hello/schema.edn")))
(def data-tx (read-string (slurp "resources/hello/seed-data.edn")))

(defn init-db []
      (log/info "starting db!")
      (d/create-database uri)
      (let [conn (d/connect uri)]
           (log/info @(d/transact conn schema-tx))
           (log/info @(d/transact conn data-tx))))

(defn results []
      (let [conn (d/connect uri)]
           (q '[:find ?c :where [?e :hello/color ?c]] (d/db conn))))
