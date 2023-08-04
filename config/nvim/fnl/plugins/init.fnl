(import-macros {: pack : setup!} :macros)

[{:dir "~/gitclone/parinfer-rust"}
 (pack :udayvir-singh/tangerine.nvim)
 (pack :nvim-lua/plenary.nvim)
 (pack :rebelot/kanagawa.nvim
       {:priority 1000
        ;; :init #(vim.cmd "colorscheme kanagawa-wave")
        :opts {:compile true
               :dimInactive true
               :colors {:theme {:all {:ui {:bg_gutter :none}}}}}})
 (pack :catppuccin/nvim
       {:priority 1000
        :init #(vim.cmd "colorscheme catppuccin-mocha")
        :config #((setup! :catppuccin) {:dim_inactive {:enabled true}
                                        :compile_path (.. (vim.fn.stdpath :cache)
                                                          :/catppuccin)
                                        :integrations {:leap true
                                                       :neotree true
                                                       :neogit true
                                                       :noice true
                                                       :treesitter_context true
                                                       :lsp_trouble true
                                                       :which_key true}})})
 (require :plugins.ui)
 (require :plugins.ide)
 ;; greeter
 (require :plugins.alpha)
 ;; completion engine
 (require :plugins.cmp)
 ;; syntax highlighting
 (require :plugins.treesitter)
 ;; syntax for Fennel
 (pack :jaawerth/fennel.vim)
 ;; syntax for yuck
 (pack :elkowar/yuck.vim)
 ;; general-purpose motion plugin
 (pack :ggandor/leap.nvim
       {:dependencies [;; f/F/t/T motions on steroids
                       (pack :ggandor/flit.nvim {:config true})
                       ;; remote operations on Vim's native text objects
                       (pack :ggandor/leap-spooky.nvim {:config true})]
        :config #(vim.api.nvim_set_hl 0 :LeapBackdrop {:link :Comment})})
 ;; organizes life in plain text
 (pack :nvim-neorg/neorg
       {:build ":Neorg sync-parsers"
        :cmd :Neorg
        :ft :norg
        :opts {:load {:core.defaults {}}
               :core.completion {:config {:engine :nvim-cmp}}
               :core.integrations.nvim-cmp {}
               :core.concealer {}
               :core.dirman {:config {:workspaces {:notes "~/Sync/neorg"}}}
               :core.journal {:config {:strategy :flat}}}})
 ;; Smooth scrolling <C-u>, <C-d> ; <C-b>, <C-f> ; <C-y>, <C-e> ; zt, zz, zb
 (pack :karb94/neoscroll.nvim {:config true :event :BufRead})
 ;; magit for neovim
 (pack :NeogitOrg/neogit {:dependencies [;; Single tabpage interface for easily cycling through diffs for all modified files for any git rev
                                         :sindrets/diffview.nvim]
                          :opts {:integrations {:diffview true}}
                          :cmd :Neogit})
 (pack :olimorris/persisted.nvim {:opts {:autosave false}})
 ;; Smart and powerful comment plugin for neovim
 (pack :numToStr/Comment.nvim
       {:config (fn []
                  ((setup! :Comment))
                  (let [ft (require :Comment.ft)]
                    (ft.set :fennel ";;%s")))})
 ;; autopairs
 (pack :m4xshen/autoclose.nvim
       {:opts {:keys {"'" {:close false}}} :event :InsertEnter})
 ;; Add/change/delete surrounding delimiter pairs with ease
 (pack :kylechui/nvim-surround {:opts {:keymaps {:insert :<C-g>s
                                                 :insert_line :<C-g>S
                                                 :normal :ys
                                                 :normal_cur :yss
                                                 :normal_line :yS
                                                 :normal_cur_line :ySS
                                                 :visual :S
                                                 :visual_line :gS
                                                 :delete :ds
                                                 :change :cs
                                                 :change_line :cS}}
                                :event :BufRead})
 ;; Replace with regex
 (pack :nvim-pack/nvim-spectre {:lazy true :config true})
 ;; A color highlighter
 (pack :NvChad/nvim-colorizer.lua
       {:opts {:filetypes [:css :scss] :user_default_options {:css true}}})
 ;; highlight and search for todo comments
 (pack :folke/todo-comments.nvim {:config true :event :BufRead})
 ;; Distraction-free coding
 (pack :folke/zen-mode.nvim {:dependencies :folke/twilight.nvim
                             :opts {:window {:options {:signcolumn :no
                                                       :number false}}}
                             :cmd [:ZenMode]})
 ;; icons
 (pack :nvim-tree/nvim-web-devicons)
 ;; calculator
 (pack :Apeiros-46B/qalc.nvim {:cmd [:Qalc :QalcAttach]})
 ;; hex editing
 (pack :RaafatTurki/hex.nvim {:config true})
 ;; helping you establish good command workflow and habit
 (pack :m4xshen/hardtime.nvim
       {:opts {:disabled_filetypes [:neo-tree
                                    :noice
                                    :NeogitStatus
                                    :spectre_panel]}})]
