(defproject io.pedestal/what-is-an-interceptor "0.5.7"
  :description "Sample project for the What is an Interceptor guide"
  :url "https://github.com/pedestal/pedestal-docs"
  :dependencies [[org.clojure/clojure "1.10.1"]
                 [io.pedestal/pedestal.service "0.5.7"]
                 [io.pedestal/pedestal.jetty "0.5.7"]
                 [org.slf4j/slf4j-api "1.7.28"]
                 [ch.qos.logback/logback-classic "1.2.3" :exclusions [[org.slf4j/slf4j-api]]]])
