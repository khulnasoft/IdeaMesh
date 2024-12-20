(ns ideamesh.khulnasoft.common.graph-test
  (:require [ideamesh.khulnasoft.common.graph :as common-graph]
            [cljs.test :refer [deftest is use-fixtures async]]
            ["fs" :as fs]
            ["path" :as node-path]))

(use-fixtures
  :each
  ;; Cleaning tmp/ before leaves last tmp/ after a test run for dev and debugging
  {:before
   #(async done
           (if (fs/existsSync "tmp")
             (fs/rm "tmp" #js {:recursive true} (fn [err]
                                                  (when err (js/console.log err))
                                                  (done)))
             (done)))})

(defn- create-ideamesh-graph
  "Creates a minimal mock graph"
  [dir]
  (fs/mkdirSync (node-path/join dir "ideamesh") #js {:recursive true})
  (fs/mkdirSync (node-path/join dir "journals"))
  (fs/mkdirSync (node-path/join dir "pages")))

(deftest get-files
  (create-ideamesh-graph "tmp/test-graph")
  ;; Create files that are recognized
  (fs/writeFileSync "tmp/test-graph/pages/foo.md" "")
  (fs/writeFileSync "tmp/test-graph/journals/2023_05_09.md" "")
  ;; Create files that are ignored
  (fs/mkdirSync (node-path/join "tmp/test-graph" "ideamesh" "bak"))
  (fs/writeFileSync "tmp/test-graph/ideamesh/bak/baz.md" "")
  (fs/writeFileSync "tmp/test-graph/ideamesh/.gitignore" "")
  (is (= ["tmp/test-graph/journals/2023_05_09.md" "tmp/test-graph/pages/foo.md"]
         (common-graph/get-files "tmp/test-graph"))))