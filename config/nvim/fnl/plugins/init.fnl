(import-macros {: pack} :macros)

[(pack :udayvir-singh/tangerine.nvim)
 (pack :eraserhd/parinfer-rust {:build "cargo build --release"})
 ; (pack :rebelot/kanagawa.nvim
 ;       {:priority 1000
 ;        ; :init #(vim.cmd "colorscheme kanagawa-wave")
 ;        :opts {:compile true
 ;               :transparent true
 ;               :dimInactive true
 ;               :colors {:theme {:all {:ui {:bg_gutter :none}}}}}})
 (pack :catppuccin/nvim
       {:priority 1000
        :name :catppuccin
        :init #(vim.cmd "colorscheme catppuccin-mocha")
        :opts {:transparent_background true
               :dim_inactive {:enabled true}
               :compile_path (.. (vim.fn.stdpath :cache) :/catppuccin)
               :integrations {:harpoon true
                              :leap true
                              :neogit true
                              :noice true
                              :treesitter_context true
                              :lsp_trouble true
                              :which_key true}}})
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
 ;; general-purpose motion plugin
 (pack :ggandor/leap.nvim
       {:dependencies [;; f/F/t/T motions on steroids
                       (pack :ggandor/flit.nvim {:config true})
                       ;; remote operations on Vim's native text objects
                       (pack :ggandor/leap-spooky.nvim {:config true})]
        :event :VeryLazy
        :config #(vim.api.nvim_set_hl 0 :LeapBackdrop {:link :Comment})})
 ;; DiRectory EXplorer
 (pack :TheBlob42/drex.nvim
       {:dependencies [:nvim-tree/nvim-web-devicons]
        :config #(let [conf (require :drex.config)]
                   (var t {})
                   (set t.hide_cursor false)
                   (set t.actions
                        {:files {:delete_cmd (and (= (vim.fn.executable :trash)
                                                     1)
                                                  :trash)}}) ; (set t.on_leave #(vim.cmd :DrexDrawerToggle))
                   (conf.configure t))})
 ;; Telescope
 (pack :nvim-telescope/telescope.nvim
       {:dependencies [:nvim-lua/plenary.nvim
                       :nvim-tree/nvim-web-devicons
                       :nvim-telescope/telescope-fzy-native.nvim
                       :nvim-telescope/telescope-ui-select.nvim]
        :cmd :Telescope
        :config #(let [telescope (require :telescope)]
                       ; trouble (require :trouble.providers.telescope)]
                   (telescope.setup {:extensions {:fzy_native {:override_generic_sorter false
                                                               :override_file_sorter true}}})
                   (telescope.load_extension :fzy_native)
                   (telescope.load_extension :harpoon)
                   (telescope.load_extension :ui-select))})
                   ; (telescope.setup {:defaults {:mappings {:i {:<c-t> trouble.open_with_trouble}
                   ;                                         :n {:<c-t> trouble.open_with_trouble}}}}))})
 ;; Getting you where you want with the fewest keystrokes
 (pack :ThePrimeagen/harpoon
       {:dependencies [:nvim-lua/plenary.nvim]
        :branch :harpoon2
        :config #(let [harpoon (require :harpoon)]
                   (harpoon:setup))})
 ;; magit for neovim
 (pack :NeogitOrg/neogit
       {:dependencies [:nvim-lua/plenary.nvim
                       ;; Single tabpage interface for easily cycling through
                       ;; diffs for all modified files for any git rev
                       :sindrets/diffview.nvim]
        :cmd :Neogit
        :opts {:integrations {:diffview true}}})
 ;; Git integration for buffers
 (pack :lewis6991/gitsigns.nvim {:event :VeryLazy :opts {:numhl true}})
 ;; popup with possible key bindings
 (pack :folke/which-key.nvim {:config true})
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
 ; (pack :folke/trouble.nvim {:dependencies [:nvim-tree/nvim-web-devicons]
 ;                            :event :VeryLazy
 ;                            :config true})
 ;; highlight and search for todo comments
 (pack :folke/todo-comments.nvim
       {:dependencies [:nvim-lua/plenary.nvim] :event :VeryLazy :config true})
 ;; Distraction-free coding
 (pack :folke/zen-mode.nvim
       {;:dependencies [:folke/twilight.nvim]
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
                                ; :opts {:surrounds {"c" {:add ["/* " " */"]
                                ;                         :find (fn []
                                ;                                 (let [config (require "nvim-surround.config")]
                                ;                                   (config.get_selection {:pattern "/%*.*%*/"})))
                                ;                         :delete "^(. ?)().-( ?.)()$"}}}})
 ;; manage undos as a tree
 (pack :jiaoshijie/undotree {:dependencies [:nvim-lua/plenary.nvim]
                             :lazy true
                             :config true})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen
       {:dependencies [:nvim-treesitter/nvim-treesitter]
        :cmd :Neogen
        :opts {:snippet_engine :luasnip}})
 ;; helps managing crates.io dependencies
 (pack :saecki/crates.nvim {:dependencies [:nvim-lua/plenary.nvim]
                            :event "BufRead Cargo.toml"
                            :config true})
 ;; calculator
 (pack :Apeiros-46B/qalc.nvim {:cmd [:Qalc :QalcAttach]})
 ;; Practise typing
 (pack :NStefan002/speedtyper.nvim {:cmd :Speedtyper :config true})]

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
;        :config (fn []
;                  ((setup! :ufo))
;                  (set vim.o.foldmethod :expr)
;                  (set vim.o.fillchars
;                       "eob: ,fold: ,foldopen:,foldsep: ,foldclose:")
;                  (set vim.o.foldcolumn :1)
;                  (set vim.o.foldlevel 99)
;                  (set vim.o.foldlevelstart 99)
;                  (set vim.o.foldenable true))})
;; frecency-based buffer switcher that allows you to hop between files
; (pack :dzfrias/arena.nvim {:config true})
;; The goal of nvim-fundo is to make Neovim's undo file become stable and useful.
; (pack :kevinhwang91/nvim-fundo {:dependencies [:kevinhwang91/promise-async]
;                                 :build #((. (require :fundo) :install))
;                                 :config true})
;; Delete Neovim buffers without losing window layout
; (pack :famiu/bufdelete.nvim)
;; Highlight colors
; (pack :brenoprata10/nvim-highlight-colors
;       {:event :VeryLazy :opts {:enable_tailwind true}})

