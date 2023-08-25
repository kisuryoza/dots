(import-macros {: pack} :macros)

[;; A minimal, stylish and customizable statusline / winbar / bufferline
 (require :plugins.ui.heirline)
 ;; completely replaces the UI for messages, cmdline and the popupmenu
 (require :plugins.ui.noice)
 ;; popup with possible key bindings
 (pack :folke/which-key.nvim {:config true})
 ;; Git integration for buffers
 (pack :lewis6991/gitsigns.nvim {:event :BufRead :opts {:numhl true}})
 ;; The simple directory tree viewer
 ; (pack :dinhhuy258/sfm.nvim)
 ;; DiRectory EXplorer
 (pack :TheBlob42/drex.nvim {:dependencies [:nvim-tree/nvim-web-devicons]
                             :config #(let [conf (require :drex.config)]
                                        (var t {})
                                        (set t.hide_cursor false)
                                        (set t.actions {:files {:delete_cmd (and (= (vim.fn.executable "trash") 1) "trash")}})
                                        ; (set t.on_leave #(vim.cmd :DrexDrawerToggle))
                                        (conf.configure t))})
 ;; Telescope
 (pack :nvim-telescope/telescope.nvim
       {:dependencies [:nvim-tree/nvim-web-devicons]
        :cmd :Telescope
        :config #(let [telescope (require :telescope)
                       trouble (require :trouble.providers.telescope)]
                   (telescope.load_extension :harpoon)
                   (telescope.setup {:defaults {:mappings {:i {:<c-t> trouble.open_with_trouble}
                                                           :n {:<c-t> trouble.open_with_trouble}}}}))})
 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 (pack :folke/trouble.nvim {:dependencies [:nvim-tree/nvim-web-devicons]
                            :event :BufRead
                            :config true})
 ;; Replaces vim.ui.select and vim.ui.input
 (pack :stevearc/dressing.nvim {:event :VeryLazy})
 ;; manage undos as a tree
 (pack :jiaoshijie/undotree {:lazy true :config true})]
 ;; Status column
 ; (pack :luukvbaal/statuscol.nvim
 ;       {:event :BufRead
 ;        :config #(let [builtin (require :statuscol.builtin)]
 ;                   (var t {})
 ;                   (set t.segments
 ;                        [{:click "v:lua.ScFa" :text [builtin.foldfunc " "]}
 ;                         {:click "v:lua.ScSa" :text ["%s"]}
 ;                         {:click "v:lua.ScLa"
 ;                          :condition [true builtin.not_empty]
 ;                          :text [builtin.lnumfunc " "]}])
 ;                   ((setup! :statuscol) t))})
 ; ;; Fold features
 ; (pack :kevinhwang91/nvim-ufo
 ;       {:dependencies [:kevinhwang91/promise-async]
 ;        :event :BufRead
 ;        :config (fn []
 ;                  ((setup! :ufo))
 ;                  (set vim.o.foldmethod :expr)
 ;                  (set vim.o.fillchars
 ;                       "eob: ,fold: ,foldopen:,foldsep: ,foldclose:")
 ;                  (set vim.o.foldcolumn :1)
 ;                  (set vim.o.foldlevel 99)
 ;                  (set vim.o.foldlevelstart 99)
 ;                  (set vim.o.foldenable true))})

