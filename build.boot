(set-env!
 :source-paths #{"src"}
 :dependencies '[[org.clojure/clojure "1.9.0-alpha10"]])

(deftask index-samples
  "Create a page with links to every sample application"
  []
  (with-pre-wrap fileset
    (require 'samples)
    (let [emitter (resolve 'samples/emit-samples-index)]
      (emitter)
      fileset)))

(deftask apidoc
  "Generate API documentation for all Pedestal modules"
  []
  (with-pre-wrap fileset
    fileset))
