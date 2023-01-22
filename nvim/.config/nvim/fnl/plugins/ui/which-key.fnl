(import-macros {: cmd
                : pack} :macros)

(local M
  (pack :folke/which-key.nvim))

(fn M.config []
  (let [wk (require :which-key)
        undotree (require :undotree)]
    (wk.setup)

    (wk.register
      {:<Esc> [(vim.api.nvim_replace_termcodes "<C-\\><C-n>" true true true) "Exit terminal mode"]}
      {:mode "t"
       :noremap false})

    (wk.register
      {:<Esc> [(cmd "noh") "Turn off highlighting"]
       :<C-t> [(cmd "tabnew") "Create new tab"]
       :<C-Left> [(cmd "tabprevious") "Previouse tab"]
       :<C-Right> [(cmd "tabnext") "Next tab"]}
      {:mode "n"
       :noremap false})

    (wk.register
      {:<TAB> [(cmd "ToggleTerm") "Open Terminal"]

       :s {:name "+Sessions"
           :c [(cmd "e $MYVIMRC | :cd %:p:h") "Edit Neovm config"]
           :l [(cmd "SessionManager load_session") "List sessions"]
           :s [(cmd "SessionManager save_current_session") "Save session"]
           :d [(cmd "SessionManager delete_session") "Delete session"]}

       :b {:name "+Buffers"
           :d [(cmd "lcd %:p:h") "Set local working dir"]
           :D [(cmd "cd %:p:h") "Set global working dir"]
           :b [(cmd "Telescope buffers") "Buffers"]
           :q [(cmd "QalcAttach") "[B] to calc"]}

       :f {:name "+Files"
           :f [(cmd "Telescope find_files") "Find Files"]
           :r [(cmd "Telescope oldfiles") "Recent"]
           :F [(cmd "Neotree toggle .") "File Manager"]
           :g [(cmd "Telescope live_grep") "Live Grep"]
           :R [(cmd "lua require('spectre').open()") "Regex replace"]}

       :c {:name "+Code"
           :z [(cmd "ZenMode") "ZenMode"]
           :x [(cmd "TroubleToggle") "List of errors"]
           :u [(. undotree :toggle) "Undotree"]}

       :g {:name "+Git"
           :n [(cmd "Neogit") "Open Neogit"]
           :s [(cmd "Telescope git_status") "Git status"]
           :l [(cmd "Gitsigns toggle_linehl") "Highlight lines"]
           :b [(cmd "Gitsigns toggle_current_line_blame") "Toggle line blame"]}

       :n {:name "+Neorg"
           :n [(cmd "Neorg") "Neorg"]
           :w [(cmd "Neorg workspace notes") "Workspace 'notes'"]
           :j [(cmd "Neorg journal") "Journal"]}

       :e ["<Plug>(leap-forward)" "Leap forward"]
       :E ["<Plug>(leap-backward)" "Leap backward"]}
      {:prefix "<localleader>"
       :noremap false})))

M
