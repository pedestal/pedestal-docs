(ns samples
  (:require [clojure.string :as str]
            [clojure.java.io :as io])
  (:import java.io.File))

(defn snake-case
  [x]
  (-> x
      (str/replace #"^[=*]+ *" "")
      str/lower-case
      (str/replace #"[^a-z ]" "")
      (str/replace " " "-")))

(defn title
  [x]
  (-> x
      (str/replace #"^[=*]+ *" "")))

(defn div
  [cls body]
  (format "<div class=\"%s\">%s</div>" (str/join " " cls) body))

(defn a
  [href cls body]
  (format "<a href=\"%s\" class=\"%s\">%s</a>" href (str/join " " cls) body))

(defn li
  [cls & es]
  (if (seq cls)
    (format "<li class=\"%s\">%s</li>" (str/join " " cls) (str/join es))
    (format "<li>%s</li>" (str/join es))))

(defn links
  [long-str]
  (for [s (str/split long-str #"\n")]
    (cond
      (str/starts-with? s "== ")
      (println (a
                (snake-case s)
                ["w-nav-link" "clj-section-nav-item-link"]
                (title s)) "\n")

      (str/starts-with? s "* ")
#_      (println (a
                 (snake-case s)
                 ["w-nav-link" "clj-section-nav-item-link"]
                 (title s)) "\n")
      "\n"

      :else
      (str s "\n"))))

;; ----------------------------------------
;; Indexing samples

;; relative to the REPL's dir
(defn samples-dir
  []
  (File. "../pedestal/samples"))

(defn readmes
  [d]
  (filter
   (fn [f]
     (let [n (.getAbsolutePath f)]
       (and (str/ends-with? n "README.md")
            (not (str/ends-with? n "samples/README.md")))))
   (file-seq d)))

(defn lines
  [f]
  (-> f
      io/reader
      slurp
      (str/split #"\n")))

(defn paragraphs
  [f]
  (-> f
      io/reader
      slurp
      (str/split #"\n\n")))

(defn setext-heading-underline?
  "True if s is a Github markdown-flavored setext-heading-underline."
  [s]
  (boolean (re-find #"\s{0,3}(={2,}|--{2,})\s*" s)))

(defn heading? [s] (or (str/starts-with? s "#")
                       (setext-heading-underline? s)))

(defn headline
  [f]
  (str/replace (first (filter heading? (lines f))) #"^#* " ""))

(defn summary
  [f]
  (first (remove heading? (paragraphs f))))

(defn link-href
  [f]
  (-> (.getPath f)
      (str/replace "../pedestal/" "https://github.com/pedestal/pedestal/tree/master/")
      (str/replace "/README.md" "")))

(defn link-text
  [f]
  (.getName (.getParentFile f)))

(defn extract-features
  [fs]
  (for [f fs]
    [(link-href f) (link-text f) (summary f)]))

(defn index-samples
  []
  (str
   "= Guide to Sample Applications\n"
   "Document Writer\n"
   "2016-08-15\n"
   ":jbake-type: page\n"
   ":toc: macro\n"
   ":icons: font\n\n"
   (str/join "\n"
             (for [r (sort-by first (extract-features (readmes (samples-dir))))
                   :let [[hr txt sum] r]]
               (str "* " hr "[" txt "] - " sum)))))

(defn emit-samples-index
  []
  (spit (File. "content/samples/index.adoc") (index-samples)))
