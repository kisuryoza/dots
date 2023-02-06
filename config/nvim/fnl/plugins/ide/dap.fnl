(import-macros {: pack : setup!} :macros)

(local M (pack :mfussenegger/nvim-dap
               {:dependencies [(pack :rcarriga/nvim-dap-ui
                                     {:config #(let [dap (require :dap)
                                                     dapui (require :dapui)]
                                                 ((. dapui :setup))
                                                 (tset dap.listeners.after.event_initialized
                                                       :dapui_config
                                                       #(dapui.open))
                                                 (tset dap.listeners.after.event_terminated
                                                       :dapui_config
                                                       #(dapui.close))
                                                 (tset dap.listeners.after.event_exited
                                                       :dapui_config
                                                       #(dapui.close)))})
                               (pack :theHamsta/nvim-dap-virtual-text
                                     {:config #((setup! :nvim-dap-virtual-text) {:all_references true
                                                                                 :text_prefix "===> "})})]
                :ft [:c :cpp :rust]}))

(fn M.config []
  (let [dap (require :dap)
        wk (require :which-key)]
    (set dap.adapters.codelldb
         {:type :server
          :port "${port}"
          :executable {:command :/usr/bin/codelldb :args [:--port "${port}"]}})
    (set dap.configurations.c
         [{:name :codelldb
           :type :codelldb
           :request :launch
           :program #(vim.fn.input "Path to executable: "
                                   (.. (vim.fn.getcwd) "/") :file)
           :cwd "${workspaceFolder}"
           :stopOnEntry false}])
    (set dap.configurations.cpp dap.configurations.c)
    (set dap.configurations.rust
         [{:name :codelldb
           :type :codelldb
           :request :launch
           :program (fn []
                      (vim.notify :Building... vim.log.levels.WARN)
                      (vim.fn.system "cargo build")
                      (let [output (vim.fn.system "cargo metadata --format-version=1 --no-deps")
                            artifact (vim.fn.json_decode output)
                            target-name (. (. (. (. artifact.packages 1)
                                                 :targets)
                                              1)
                                           :name)
                            target-dir artifact.target_directory]
                        (vim.notify (.. "Binary name: " target-name)
                                    vim.log.levels.INFO)
                        (.. target-dir :/debug/ target-name)))}])
    (wk.register {:d {:name :+DAP
                      :t [#((. dap :terminate)) :Terminate]
                      :c [#((. dap :continue)) :Continue]
                      :s {:name :+Step
                          :o [#((. dap :step_over)) "Step over"]
                          :i [#((. dap :step_into)) "Step into"]
                          :O [#((. dap :step_out)) "Step out"]}
                      :b [#((. dap :toggle_breakpoint)) "Toggle breakpoint"]
                      :B {:name :+Breakpoints
                          :b [#((. dap :set_breakpoint) nil nil
                                                        (vim.fn.input "Log msg: "))
                              "Set breakpoint"]
                          :s [#((. dap :set_breakpoint) (vim.fn.input "Breakpoint condition: ")
                                                        (vim.fn.input "Breakpoint hit condition: ")
                                                        (vim.fn.input "Log msg: "))
                              "Set breakpoint with conditions"]}
                      :d {:r [#((. (. dap :repl) :open)) "Repl open"]
                          :l [#((. dap :run_last)) "Run last"]}}}
                 {:prefix :<localleader> :silent true})))

M

