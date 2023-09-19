(import-macros {: pack} :macros)

[(pack :udayvir-singh/tangerine.nvim)
 (pack :eraserhd/parinfer-rust {:build "cargo build --release"})
 (pack :nvim-lua/plenary.nvim)
 (pack :rebelot/kanagawa.nvim
       {:priority 1000
        ; :init #(vim.cmd "colorscheme kanagawa-wave")
        :opts {:compile true
               :transparent true
               :dimInactive true
               :colors {:theme {:all {:ui {:bg_gutter :none}}}}}})
 (pack :catppuccin/nvim
       {:priority 1000
        :name :catppuccin
        :init #(vim.cmd "colorscheme catppuccin-mocha")
        :opts {:transparent_background true
               :dim_inactive {:enabled true}
               :compile_path (.. (vim.fn.stdpath :cache) :/catppuccin)
               :integrations {:leap true
                              :neotree true
                              :neogit true
                              :noice true
                              :treesitter_context true
                              :lsp_trouble true
                              :which_key true}}})
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
 ;; Getting you where you want with the fewest keystrokes
 (pack :ThePrimeagen/harpoon)
 ;; magit for neovim
 (pack :NeogitOrg/neogit {:cmd :Neogit :opts {:integrations {:diffview true}}})
 ;; Single tabpage interface for easily cycling through diffs for all modified files for any git rev
 (pack :sindrets/diffview.nvim
       {:dependencies [:nvim-tree/nvim-web-devicons] :cmd :DiffviewOpen})
 ;; Smart and powerful comment plugin for neovim
 (pack :numToStr/Comment.nvim {:event :BufRead :config true})
 ;; autopairs
 (pack :m4xshen/autoclose.nvim
       {:event :BufRead :opts {:keys {"'" {:close false}}}})
 ;; Add/change/delete surrounding delimiter pairs with ease
 (pack :kylechui/nvim-surround {:event :BufRead :config true})
 ;; Replace with regex
 (pack :nvim-pack/nvim-spectre {:lazy true :config true})
 ;; Highlight colors
 (pack :brenoprata10/nvim-highlight-colors
       {:event :BufRead :opts {:enable_tailwind true}})
 ;; highlight and search for todo comments
 (pack :folke/todo-comments.nvim {:event :BufRead :config true})
 ;; Distraction-free coding
 (pack :folke/zen-mode.nvim
       {:dependencies :folke/twilight.nvim
        :cmd :ZenMode
        :opts {:window {:options {:signcolumn :no :number false}}}})
 ;; calculator
 (pack :Apeiros-46B/qalc.nvim {:cmd [:Qalc :QalcAttach]})
 ;; The goal of nvim-fundo is to make Neovim's undo file become stable and useful.
 (pack :kevinhwang91/nvim-fundo {:dependencies [:kevinhwang91/promise-async]
                                 :build #((. (require :fundo) :install))
                                 :config true})
 ;; Practise typing
 (pack :NStefan002/speedtyper.nvim {:cmd :Speedtyper :config true})
 ;; helping you establish good command workflow and habit
 (pack :m4xshen/hardtime.nvim
       {:opts {:disabled_filetypes [:lazy
                                    :mason
                                    :drex
                                    :noice
                                    :NeogitStatus
                                    :NeogitPopup
                                    :spectre_panel
                                    :qf
                                    :crates.nvim
                                    :harpoon
                                    :help
                                    :checkhealth]}})]
 ;; Delete Neovim buffers without losing window layout
 ; (pack :famiu/bufdelete.nvim)

