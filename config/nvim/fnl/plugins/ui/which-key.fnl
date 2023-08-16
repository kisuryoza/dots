(import-macros {: cmd : pack} :macros)

(local M (pack :folke/which-key.nvim))

(fn M.config []
  (set vim.o.timeout true)
  (set vim.o.timeoutlen 300)
  (local wk (require :which-key))
  (local ufo (require :ufo))
  (fn toggle-opt [option on off]
    (var curr_value (: (. vim.opt option) :get))
    (if (= (type curr_value) :table)
        (set curr_value (. curr_value (next curr_value))))
    (if (= curr_value on)
        (tset vim.opt option off)
        (tset vim.opt option on)))
  (wk.register {:<Esc> [(vim.api.nvim_replace_termcodes "<C-\\><C-n>" true true
                                                        true)
                        "Exit terminal mode"]}
               {:mode :t :noremap false})
  (wk.register {:<Esc> [(cmd :noh) "Turn off highlighting"]
                :<C-t> [(cmd :tabnew) "Create new tab"]
                :<C-Left> [(cmd :tabprevious) "Previouse tab"]
                :<C-Right> [(cmd :tabnext) "Next tab"]
                :<Tab> ["<Plug>(leap-forward)" "Leap forward"]
                :<S-Tab> ["<Plug>(leap-backward)" "Leap backward"]
                :z {:name :+ufo
                    :R [#(ufo.openAllFolds) :openAllFolds]
                    :M [#(ufo.closeAllFolds) :closeAllFolds]
                    :r [#(ufo.openFoldsExceptKinds) :openFoldsExceptKinds]
                    :m [#(ufo.closeFoldsWith 3) :closeFoldsWith]}}
               {:mode :n :noremap false})
  (wk.register {:y [:ygv<esc> "Yank sel text w/out moving cursor back"]
                :J [":m '>+1<CR>gv=gv" "Move selected Down"]
                :K [":m '<-2<CR>gv=gv" "Move selected Up"]}
               {:mode :v :noremap false})
  (wk.register {:<TAB> [(cmd :ToggleTerm) "Open Terminal"]
                :z [(cmd :ZenMode) :ZenMode]
                :s {:name :+Sessions
                    :c [(cmd "e $MYVIMRC | :cd %:p:h") "Edit Neovm config"]
                    :l [(cmd "Telescope persisted") "List sessions"]
                    :s [(cmd :SessionSave) "Save session"]
                    :d [(cmd :SessionDelete) "Delete session"]}
                :b {:name :+Buffers
                    :d [(cmd "lcd %:p:h") "Set local working dir"]
                    :D [(cmd "cd %:p:h") "Set global working dir"]
                    :b [(cmd "Telescope buffers") :Buffers]}
                :f {:name :+Files
                    :f [(cmd "Telescope find_files") "Find Files"]
                    :r [(cmd "Telescope oldfiles") :Recent]
                    :F [(cmd "Neotree toggle .") "File Manager"]
                    :g [(cmd "Telescope live_grep") "Live Grep"]
                    :R [(cmd "lua require('spectre').open()") "Regex replace"]}
                :c {:name :+Code
                    :a [vim.lsp.buf.code_action "Code actions"]
                    :f [#(vim.lsp.buf.format {:async true}) "Format buffer"]
                    :x [(cmd :TroubleToggle) "List of errors"]
                    :t [(cmd :TodoTrouble) "List of TODOs"]
                    :u [#((. (require :undotree) :toggle)) :Undotree]}
                :g {:name :+Git
                    :n [(cmd :Neogit) "Open Neogit"]
                    :l [(cmd "Gitsigns toggle_linehl") "Highlight lines"]
                    :b [(cmd "Gitsigns toggle_current_line_blame")
                        "Toggle line blame"]
                    :h {:name :+Hunk
                        :r [(cmd "Gitsigns reset_hunk") "Reset hunk"]
                        :P [(cmd "Gitsigns preview_hunk_inline")
                            "Preview hunk"]
                        :p [(cmd "Gitsigns prev_hunk") "Prev hunk"]
                        :n [(cmd "Gitsigns next_hunk") "Next hunk"]
                        :s [(cmd "Gitsigns select_hunk") "Select hunk"]}}
                :o {:name :+Options
                    :n [#(toggle-opt :number true false) :Number]
                    :r [#(toggle-opt :relativenumber true false) "Relative number"]
                    :v [#(toggle-opt :virtualedit :all :block) "Virtual edit"]
                    :i [#(toggle-opt :list true false) "Show invisible"]
                    :s [#(toggle-opt :spell true false) :Spell]
                    :w [#(toggle-opt :wrap true false) :Wrap]
                    :c [#(toggle-opt :colorcolumn :80 :0) "Color column"]
                    :l [#(toggle-opt :cursorline true false) "Cursor line"]}}
               {:prefix :<leader> :noremap false}))

M
