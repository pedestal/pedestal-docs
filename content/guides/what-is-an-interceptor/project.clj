(defproject io.pedestal/what-is-an-interceptor "0.5.2"
  :description "Sample project for the What is an Interceptor guide"
  :url "https://github.com/pedestal/pedestal-docs"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [io.pedestal/pedestal.service "0.5.2"]
                 [io.pedestal/pedestal.jetty "0.5.2"]
                 [org.slf4j/slf4j-api "1.7.22"]
                 [ch.qos.logback/logback-classic "1.1.8" :exclusions [[org.slf4j/slf4j-api]]]])
