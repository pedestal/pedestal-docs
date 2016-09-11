;; tag::ns[]
(ns routes)
;; end::ns[]

;; tag::response[]
(defn respond-hello [request]
  {:status 200 :body "Hello, world!"})
;; end::response[]

;; tag::routes[]
(def routes
  #{["/greet" :get respond-hello :route-name :greet]})
;; end::routes[]
