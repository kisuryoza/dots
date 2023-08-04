(import-macros {: pack : setup!} :macros)

[;; A minimal, stylish and customizable statusline / winbar / bufferline
 (require :plugins.ui.heirline)
 ;; completely replaces the UI for messages, cmdline and the popupmenu
 (require :plugins.ui.noice)
 ;; popup with possible key bindings
 (require :plugins.ui.which-key)
 ;; Git integration for buffers
 (pack :lewis6991/gitsigns.nvim {:event :BufRead :opts {:numhl true}})
 ;; manage the file system and other tree like structures
 (pack :nvim-neo-tree/neo-tree.nvim
       {:dependencies [:nvim-tree/nvim-web-devicons :MunifTanjim/nui.nvim]
        :config (fn []
                  (vim.cmd "let g:neo_tree_remove_legacy_commands = 1")
                  (let [manager (require :neo-tree.sources.manager)]
                    (var t {})
                    (set t.event_handlers
                         [{:event :file_opened
                           :handler (fn [_file_path]
                                      (manager.close_all))}])
                    ((setup! :neo-tree) t)))})
 ;; Telescope
 (pack :nvim-telescope/telescope.nvim
       {:config (fn []
                  (let [telescope (require :telescope)
                        actions (require :telescope.actions)]
                    (telescope.load_extension :persisted)
                    (telescope.setup {:defaults {:mappings {:i {:<esc> actions.close}}}})))})
 ;; Status column
 (pack :luukvbaal/statuscol.nvim
       {:config (fn []
                  (let [builtin (require :statuscol.builtin)]
                    (var t {})
                    (set t.relculright true)
                    (set t.segments
                         [{:click "v:lua.ScFa" :text [builtin.foldfunc " "]}
                          {:click "v:lua.ScSa" :text ["%s"]}
                          {:click "v:lua.ScLa"
                           :condition [true builtin.not_empty]
                           :text [builtin.lnumfunc " "]}])
                    ((setup! :statuscol) t)))})
 ;; Fold features
 (pack :kevinhwang91/nvim-ufo
       {:dependencies [:kevinhwang91/promise-async]
        :config (fn []
                  ((setup! :ufo))
                  (set vim.o.foldmethod :expr)
                  (set vim.o.fillchars
                       "eob: ,fold: ,foldopen:,foldsep: ,foldclose:")
                  (set vim.o.foldcolumn :1)
                  (set vim.o.foldlevel 99)
                  (set vim.o.foldlevelstart 99)
                  (set vim.o.foldenable true))})
 ;; Replaces vim.ui.select and vim.ui.input
 (pack :stevearc/dressing.nvim)
 ;; manage multiple terminal windows
 (pack :akinsho/toggleterm.nvim {:opts {:direction :float} :cmd :ToggleTerm})
 ;; manage undos as a tree
 (pack :jiaoshijie/undotree {:config true})]
