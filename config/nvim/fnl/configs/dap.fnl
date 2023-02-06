(local M {})

(fn contains [list item]
  (each [_ val (ipairs list)]
    (when (= item val)
      (lua "return true")))
  false)

(fn M.start []
  (local dap (require "dap"))
  (local Job (require "plenary.job"))
  (: (Job:new {:command "cargo"
               :args ["build" "--message-format=json"]
               :cwd (vim.fn.getcwd)
               :on_exit (fn [j code]
                          (when (> code 0)
                            (vim.notify "An error occurred while compiling" vim.log.levels.ERROR)
                            (lua "return"))
                          (vim.schedule (fn []
                                          (var executables "")
                                          (each [_ value (pairs (j:result))]
                                            (let [artifact (vim.fn.json_decode value)]
                                              (when (and (= (type artifact) :table) (= artifact.reason :compiler-artifact))
                                                (let [is-kind-bin (contains artifact.target.kind "bin")
                                                      is-crate_types-bin (contains artifact.target.crate_types "bin")]
                                                  (when (and is-kind-bin is-crate_types-bin)
                                                    (set executables (tostring artifact.executable)))))))
                                                    ;; (table:insert executables artifact.executable)
                                                    ;; (vim.notify (tostring artifact.executable) vim.log.levels.WARN)))))))))})
                                          ;; (. executables 1)
                                          (print executables)
                                          (let [config {:name "Debuging"
                                                        :type :codelldb
                                                        :request :launch
                                                        :program executables
                                                        :cwd "${workspaceFolder}"
                                                        :stopOnEntry false}]
                                            (dap.run config)))))})
     :start))

M
