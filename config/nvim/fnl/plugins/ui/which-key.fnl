(import-macros {: cmd : pack} :macros)

(local M (pack :folke/which-key.nvim))

(fn M.config []
  (set vim.o.timeout true)
  (set vim.o.timeoutlen 300)

  (fn toggle-opt [option on off]
    (var curr_value (: (. vim.opt option) :get))
    (if (= (type curr_value) :table)
        (set curr_value (. curr_value (next curr_value))))
    (vim.print curr_value)
    (if (= curr_value on)
        (tset vim.opt option off)
        (tset vim.opt option on)))

  (let [wk (require :which-key)
        undotree (require :undotree)
        possession (require :possession.commands)]
    (wk.register {:<Esc> [(vim.api.nvim_replace_termcodes "<C-\\><C-n>" true
                                                          true true)
                          "Exit terminal mode"]}
                 {:mode :t :noremap false})
    (wk.register {:<Esc> [(cmd :noh) "Turn off highlighting"]
                  :<C-t> [(cmd :tabnew) "Create new tab"]
                  :<C-Left> [(cmd :tabprevious) "Previouse tab"]
                  :<C-Right> [(cmd :tabnext) "Next tab"]
                  :<Tab> ["<Plug>(leap-forward)" "Leap forward"]
                  :<S-Tab> ["<Plug>(leap-backward)" "Leap backward"]}
                 {:mode :n :noremap false})
    (wk.register {:<TAB> [(cmd :ToggleTerm) "Open Terminal"]
                  :s {:name :+Sessions
                      :c [(cmd "e $MYVIMRC | :cd %:p:h") "Edit Neovm config"]
                      :l [(cmd "Telescope possession list") "List sessions"]
                      :s [#(possession.save (vim.fn.input "Session name: "))
                          "Save session"]
                      :d [#(possession.delete) "Delete session"]}
                  :b {:name :+Buffers
                      :d [(cmd "lcd %:p:h") "Set local working dir"]
                      :D [(cmd "cd %:p:h") "Set global working dir"]
                      :b [(cmd "Telescope buffers") :Buffers]
                      :w [#(toggle-opt :wrap true false) "Toggle Wrap"]
                      :c [#(toggle-opt :colorcolumn :80 :0)
                          "Toggle Colorcolumn"]}
                  :f {:name :+Files
                      :f [(cmd "Telescope find_files") "Find Files"]
                      :r [(cmd "Telescope oldfiles") :Recent]
                      :F [(cmd "Neotree toggle .") "File Manager"]
                      :g [(cmd "Telescope live_grep") "Live Grep"]
                      :R [(cmd "lua require('spectre').open()")
                          "Regex replace"]}
                  :c {:name :+Code
                      :a [vim.lsp.buf.code_action "Code actions"]
                      :f [#(vim.lsp.buf.format {:async true}) "Format buffer"]
                      :x [(cmd :TroubleToggle) "List of errors"]
                      :t [(cmd :TodoTrouble) "List of TODOs"]
                      :u [#(undotree.toggle) :Undotree]}
                  :g {:name :+Git
                      :n [(cmd :Neogit) "Open Neogit"]
                      :l [(cmd "Gitsigns toggle_linehl") "Highlight lines"]
                      :b [(cmd "Gitsigns toggle_current_line_blame")
                          "Toggle line blame"]}
                  :n {:name :+Neorg
                      :n [(cmd :Neorg) :Neorg]
                      :w [(cmd "Neorg workspace notes") "Workspace 'notes'"]
                      :j [(cmd "Neorg journal") :Journal]}}
                 {:prefix :<leader> :noremap false})))

M
