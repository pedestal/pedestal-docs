(set-env!
 :resource-paths #{"src"}                                  ;; <1>
 :dependencies   '[[io.pedestal/pedestal.service "0.5.1"]  ;; <2>
                   [io.pedestal/pedestal.route   "0.5.1"]
                   [io.pedestal/pedestal.jetty   "0.5.1"]
                   [org.slf4j/slf4j-simple       "1.7.21"]])
