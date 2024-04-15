(import-macros {: pack : nmapp!} :macros)

(local M (pack :mfussenegger/nvim-dap
               {:dependencies [(pack :nvim-neotest/nvim-nio)
                               (pack :rcarriga/nvim-dap-ui
                                     {:config #(let [dap (require :dap)
                                                     dapui (require :dapui)]
                                                 (dapui.setup)
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
                                     {:opts {:all_references true
                                             :text_prefix "===> "}})]
                :ft [:c :cpp :rust]}))

(fn M.config []
  (local dap (require :dap))
  (set dap.adapters.codelldb
       {:type :server
        :port "${port}"
        :executable {:command :/usr/bin/codelldb :args [:--port "${port}"]}})
  (set dap.configurations.c [{:name :codelldb
                              :type :codelldb
                              :request :launch
                              :program #(vim.fn.input "Path to executable: "
                                                      (.. (vim.fn.getcwd) "/")
                                                      :file)
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
                          target-name (. (. (. (. artifact.packages 1) :targets)
                                            1)
                                         :name)
                          target-dir artifact.target_directory]
                      (vim.notify (.. "Binary name: " target-name)
                                  vim.log.levels.INFO)
                      (.. target-dir :/debug/ target-name)))}])
  (nmapp! :dt #(dap.terminate) :Terminate)
  (nmapp! :dc #(dap.continue) :Continue)
  (nmapp! :dso #(dap.step_over) "Step over")
  (nmapp! :dsi #(dap.step_into) "Step into")
  (nmapp! :dsO #(dap.step_out) "Step out")
  (nmapp! :db #(dap.toggle_breakpoint) "Toggle breakpoint")
  (nmapp! :dBb #(dap.set_breakpoint nil nil (vim.fn.input "Log msg: "))
          "Set breakpoint")
  (nmapp! :dBs
          #(dap.set_breakpoint (vim.fn.input "Breakpoint condition: "
                                             (vim.fn.input "Breakpoint hit condition: ")
                                             (vim.fn.input "Log msg: ")))
          "Set breakpoint with conditions")
  (nmapp! :ddr #(dap.repl.open) "Repl open")
  (nmapp! :ddl #(dap.run_last) "Run last"))

M

