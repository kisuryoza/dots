(require-macros :macros)

[(pack :udayvir-singh/tangerine.nvim)
 (pack :eraserhd/parinfer-rust {:build "cargo build --release"})
 ; (pack :rebelot/kanagawa.nvim
 ;       {:priority 1000
 ;        :init #(if (not= (os.getenv :TERM) "linux")
 ;                   (vim.cmd "colorscheme kanagawa-wave"))
 ;        :opts {:compile true
 ;               :transparent true
 ;               :dimInactive true
 ;               :colors {:theme {:all {:ui {:bg_gutter :none}}}}}})
 (pack :catppuccin/nvim
       {:priority 1000
        :name :catppuccin
        :init #(if (not= (os.getenv :TERM) :linux)
                   (vim.cmd "colorscheme catppuccin-mocha"))
        :opts {:transparent_background true
               :dim_inactive {:enabled true}
               :compile_path (.. (vim.fn.stdpath :cache) :/catppuccin)
               :integrations {:harpoon true
                              :leap true
                              :neogit true
                              :noice true
                              :treesitter_context true
                              :lsp_trouble true
                              :which_key true
                              :fidget true}}})
 (require :plugins.lspconfig)
 (require :plugins.dap)
 ;; greeter
 (require :plugins.alpha)
 ;; completion engine
 (require :plugins.cmp)
 ;; syntax highlighting
 (require :plugins.treesitter)
 ;; A minimal, stylish and customizable statusline / winbar / bufferline
 (require :plugins.heirline)
 ;; Telescope
 (require :plugins.telescope)
 ;; Getting you where you want with the fewest keystrokes
 (require :plugins.harpoon)
 ;; Git integration for buffers
 (require :plugins.gitsigns)
 ;; helps managing crates.io dependencies
 (require :plugins.crates)
 ;; general-purpose motion plugin
 (pack :ggandor/leap.nvim
       {:dependencies [;; f/F/t/T motions on steroids
                       (pack :ggandor/flit.nvim {:config true})
                       ;; remote operations on Vim's native text objects
                       (pack :ggandor/leap-spooky.nvim {:config true})]
        :event :VeryLazy
        :config (fn []
                  (vim.api.nvim_set_hl 0 :LeapBackdrop {:link :Comment})
                  (nmap! :s "<Plug>(leap-forward)" "Leap forward")
                  (nmap! :S "<Plug>(leap-backward)" "Leap backward")
                  (nmap! :gs "<Plug>(leap-from-window)" "Leap from window"))})
 ;; DiRectory EXplorer
 (pack :TheBlob42/drex.nvim
       {:dependencies [:nvim-tree/nvim-web-devicons]
        :event :VeryLazy
        :config #(let [conf (require :drex.config)]
                   (var t {})
                   (set t.hide_cursor false)
                   (set t.actions
                        {:files {:delete_cmd (and (= (vim.fn.executable :trash)
                                                     1)
                                                  :trash)}})
                   ; (set t.on_leave #(vim.cmd :DrexDrawerToggle))
                   (conf.configure t))})
 ;; magit for neovim
 (pack :NeogitOrg/neogit
       {:dependencies [:nvim-lua/plenary.nvim
                       ;; Single tabpage interface for easily cycling through
                       ;; diffs for all modified files for any git rev
                       :sindrets/diffview.nvim]
        :event :VeryLazy
        :config #(let [neogit (require :neogit)]
                   (nmapp! :gn neogit.open "Open Neogit")
                   (neogit.setup {:integrations {:diffview true}}))})
 ;; popup with possible key bindings
 (pack :folke/which-key.nvim {:config true})
 ;; highlight and search for todo comments
 (pack :folke/todo-comments.nvim
       {:dependencies [:nvim-lua/plenary.nvim]
        :event :VeryLazy
        :config #(let [todo-comments (require :todo-comments)]
                   (nmapp! :ct (cmd! :TodoQuickFix) "List of TODOs")
                   (todo-comments.setup))})
 ;; Distraction-free coding
 (pack :folke/zen-mode.nvim {;:dependencies [:folke/twilight.nvim]
                             :cmd :ZenMode
                             :config true})
 ;; Smart and powerful comment plugin for neovim
 (pack :numToStr/Comment.nvim {:event :VeryLazy :config true})
 ;; autopairs
 (pack :m4xshen/autoclose.nvim
       {:event :VeryLazy :opts {:keys {"'" {:close false}}}})
 ;; Add/change/delete surrounding delimiter pairs with ease
 (pack :kylechui/nvim-surround {:dependencies [:nvim-treesitter/nvim-treesitter]
                                :event :VeryLazy
                                :config true})
 ;; manage undos as a tree
 (pack :jiaoshijie/undotree
       {:dependencies [:nvim-lua/plenary.nvim]
        :event :VeryLazy
        :config #(let [undotree (require :undotree)]
                   (undotree.setup)
                   (nmapp! :cu undotree.toggle :Undotree))})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen
       {:dependencies [:nvim-treesitter/nvim-treesitter]
        :cmd :Neogen
        :opts {:snippet_engine :luasnip}})
 ;; calculator
 (pack :Apeiros-46B/qalc.nvim {:cmd [:Qalc :QalcAttach]})
 ;; Practise typing
 (pack :NStefan002/speedtyper.nvim {:cmd :Speedtyper :config true})]

;; completely replaces the UI for messages, cmdline and the popupmenu
; (pack :folke/noice.nvim
;       {:dependencies [:MunifTanjim/nui.nvim :nvim-treesitter/nvim-treesitter]
;        :opts {:lsp {:override {:vim.lsp.util.convert_input_to_markdown_lines true}
;                     :vim.lsp.util.stylize_markdown true
;                     :cmp.entry.get_documentation true}
;               :presets {:bottom_search true
;                         :command_palette true
;                         :long_message_to_split true
;                         :inc_rename false
;                         :lsp_doc_border false}
;               :views {:cmdline_popup {:border {:style :none :padding [1 3]}}
;                       :filter_options {}
;                       :win_options {:winhighlight "NormalFloat:NormalFloat,FloatBorder:FloatBorder"}}
;               :routes [{:view :notify :filter {:event :msg_showmode}}]}})
;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
; (pack :folke/trouble.nvim
;       {:dependencies [:nvim-tree/nvim-web-devicons]
;        :event :VeryLazy
;        :config #(let [trouble (require :trouble)]
;                   (nmapp! :cx (cmd! :TroubleToggle) "List of errors")
;                   (trouble.setup))})
;; Status column
; (pack :luukvbaal/statuscol.nvim
;       {:event :VeryLazy
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
;       {:dependencies [:kevinhwang91/promise-async :nvim-treesitter/nvim-treesitter]
;        :event :VeryLazy
;        :config #(let [ufo (require :ufo)]
;                   (ufo.setup)
;                   (nmap! :zR ufo.openAllFolds :openAllFolds)
;                   (nmap! :zM ufo.closeAllFolds :closeAllFolds)
;                   (nmap! :zr ufo.openFoldsExceptKinds :openFoldsExceptKinds)
;                   (nmap! :zm #(ufo.closeFoldsWith 3) :closeFoldsWith)
;                   (set vim.o.foldmethod :expr)
;                   (set vim.o.fillchars
;                        "eob: ,fold: ,foldopen:,foldsep: ,foldclose:")
;                   (set vim.o.foldcolumn :1)
;                   (set vim.o.foldlevel 99)
;                   (set vim.o.foldlevelstart 99)
;                   (set vim.o.foldenable true))})
;; Highlight colors
; (pack :brenoprata10/nvim-highlight-colors
;       {:event :VeryLazy :opts {:enable_tailwind true}})

