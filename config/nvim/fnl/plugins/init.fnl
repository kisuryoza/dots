(import-macros {: pack : setup!} :macros)

[(pack :udayvir-singh/tangerine.nvim)
 (pack :eraserhd/parinfer-rust {:build "cargo build --release"})
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
 ;; general-purpose motion plugin
 (pack :ggandor/leap.nvim
       {:dependencies [;; f/F/t/T motions on steroids
                       (pack :ggandor/flit.nvim {:config true})
                       ;; remote operations on Vim's native text objects
                       (pack :ggandor/leap-spooky.nvim {:config true})]
        :event :BufRead
        :config #(vim.api.nvim_set_hl 0 :LeapBackdrop {:link :Comment})})
 ;; Smooth scrolling <C-u>, <C-d> ; <C-b>, <C-f> ; <C-y>, <C-e> ; zt, zz, zb
 (pack :karb94/neoscroll.nvim {:event :BufRead :config true})
 ;; magit for neovim
 (pack :NeogitOrg/neogit
       {:dependencies [;; Single tabpage interface for easily cycling through diffs for all modified files for any git rev
                       :sindrets/diffview.nvim]
        :cmd :Neogit
        :opts {:integrations {:diffview true}}})
 ;; Simple session management for Neovim with git branching, autoloading and Telescope support
 (pack :olimorris/persisted.nvim {:opts {:autosave false}})
 ;; Smart and powerful comment plugin for neovim
 (pack :numToStr/Comment.nvim {:event :BufRead :config true})
 ;; autopairs
 (pack :m4xshen/autoclose.nvim
       {:event :InsertEnter :opts {:keys {"'" {:close false}}}})
 ;; Add/change/delete surrounding delimiter pairs with ease
 (pack :kylechui/nvim-surround
       {:event :BufRead
        :opts {:keymaps {:insert :<C-g>s
                         :insert_line :<C-g>S
                         :normal :ys
                         :normal_cur :yss
                         :normal_line :yS
                         :normal_cur_line :ySS
                         :visual :S
                         :visual_line :gS
                         :delete :ds
                         :change :cs
                         :change_line :cS}}})
 ;; Replace with regex
 (pack :nvim-pack/nvim-spectre {:lazy true :config true})
 ;; A color highlighter
 (pack :NvChad/nvim-colorizer.lua
       {:event :BufRead
        :opts {:filetypes [:css :scss] :user_default_options {:css true}}})
 ;; highlight and search for todo comments
 (pack :folke/todo-comments.nvim {:event :BufRead :config true})
 ;; Distraction-free coding
 (pack :folke/zen-mode.nvim
       {:dependencies :folke/twilight.nvim
        :cmd :ZenMode
        :opts {:window {:options {:signcolumn :no :number false}}}})
 ;; calculator
 (pack :Apeiros-46B/qalc.nvim {:cmd [:Qalc :QalcAttach]})
 ;; hex editing
 (pack :RaafatTurki/hex.nvim {:config true})
 ;; helping you establish good command workflow and habit
 (pack :m4xshen/hardtime.nvim
       {:opts {:disabled_filetypes [:lazy
                                    :mason
                                    :neo-tree
                                    :noice
                                    :NeogitStatus
                                    :NeogitPopup
                                    :spectre_panel
                                    :checkhealth
                                    :toggleterm]}})
 ;; Flow state (bionic) reading in neovim
 (pack :nullchilly/fsread.nvim {:cmd [:FSRead :FSClear :FSToggle]})]

