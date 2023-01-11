(import-macros {: pack
                : setup!
                : cmd} :macros)

;; Debug Adapter Protocol client implementation
(local M
  (pack :mfussenegger/nvim-dap {:dependencies [(pack :rcarriga/nvim-dap-ui {:config #(let [dap (require :dap)
                                                                                           dapui (require :dapui)]
                                                                                       (dapui.setup)
                                                                                       (tset dap.listeners.after.event_initialized :dapui_config #(dapui.open))
                                                                                       (tset dap.listeners.after.event_terminated :dapui_config #(dapui.close))
                                                                                       (tset dap.listeners.after.event_exited :dapui_config #(dapui.close)))})
                                               (pack :theHamsta/nvim-dap-virtual-text {:config #((setup! :nvim-dap-virtual-text) {:all_references true
                                                                                                                                  :text_prefix "===> "})})]}))

(fn M.config []
  (let [dap (require :dap)]

    (set dap.adapters.codelldb {:type "server"
                                :port "${port}"
                                :executable {:command "/usr/bin/codelldb"
                                             :args ["--port" "${port}"]}})
    (set dap.configurations.cpp [{:name "Launch file"
                                  :type "codelldb"
                                  :request "launch"
                                  :program #(vim.fn.input "Path to executable: " (.. (vim.fn.getcwd) "/") "file")
                                  :cwd "${workspaceFolder}"
                                  :stopOnEntry false}])
    (set dap.configurations.c dap.configurations.cpp)
    (set dap.configurations.rust dap.configurations.cpp))

  (let [wk (require :which-key)]
    (wk.register
      {:d {:name "+DAP"
           :t [(cmd "lua require'dap'.terminate()") "Terminate"]
           :c [(cmd "lua require'dap'.continue()") "Continue"]
           :s {:name "+Step"
               :o [(cmd "lua require'dap'.step_over()") "Step over"]
               :i [(cmd "lua require'dap'.step_into()") "Step into"]
               :O [(cmd "lua require'dap'.step_out()") "Step out"]}
           :b [(cmd "lua require'dap'.toggle_breakpoint()") "Toggle breakpoint"]
           :B [(cmd "lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))") "Set breakpoint"]
           :lp [(cmd "lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))") "Set breakpoint"]
           :d {:r [(cmd "lua require'dap'.repl.open()") "Repl open"]
               :l [(cmd "lua require'dap'.run_last()") "Run last"]}}}
      {:prefix "<localleader>"
       :silent true})))

M
