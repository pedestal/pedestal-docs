(defproject hello "0.1.0-SNAPSHOT"
            :description "Hello World with pedestal and datomic!"
            :repositories [["my.datomic.com" {:url "https://my.datomic.com/repo"
                                              :creds :gpg}]] ;;<1>
            :dependencies [[org.clojure/clojure "1.11.1"]
                           [io.pedestal/pedestal.service "0.5.7"]
                           [io.pedestal/pedestal.route "0.5.7"]
                           [io.pedestal/pedestal.jetty "0.5.7"]
                           [org.slf4j/slf4j-simple "1.7.28"]
                           [com.datomic/datomic-pro "${VERSION}"]]
            :resource-paths ["config", "resources"]
            :source-paths ["src"])
