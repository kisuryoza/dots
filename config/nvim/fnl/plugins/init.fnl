(import-macros {: pack : setup!} :macros)

[{:dir "~/gitclone/parinfer-rust"}
 (pack :udayvir-singh/tangerine.nvim)
 (pack :nvim-lua/plenary.nvim)
 (pack :rebelot/kanagawa.nvim
       {:priority 1000
        :init #(vim.cmd "colorscheme kanagawa")
        :config #((setup! :kanagawa) {:dimInactive true :globalStatus true})})
 (pack :folke/tokyonight.nvim
       {:priority 1000
        ;; :init #(vim.cmd "colorscheme tokyonight-night")
        :config #((setup! :tokyonight) {:dim_inactive true})})
 (require :plugins.ui)
 (require :plugins.ide)
 ;; greeter
 (require :plugins.alpha)
 ;; completion engine
 (require :plugins.cmp)
 ;; snippet engine
 (require :plugins.snippets)
 ;; Snippet creation tool for Neovim
 ;; (pack :ziontee113/SnippetGenie {:config #((setup! :SnippetGenie))})
 ;; organizes life in plain text
 (require :plugins.neorg)
 ;; syntax highlighting
 (require :plugins.treesitter)
 ;; syntax for Fennel
 (pack :jaawerth/fennel.vim)
 ;; syntax for yuck
 (pack :elkowar/yuck.vim)
 ;; general-purpose motion plugin
 (pack :ggandor/leap.nvim
       {:dependencies [;; f/F/t/T motions on steroids
                       (pack :ggandor/flit.nvim {:config #((setup! :flit))})
                       ;; remote operations on Vim's native text objects
                       (pack :ggandor/leap-spooky.nvim
                             {:config #((setup! :leap-spooky))})]
        :config #(vim.api.nvim_set_hl 0 :LeapBackdrop {:link :Comment})})
 ;; Smooth scrolling <C-u>, <C-d> ; <C-b>, <C-f> ; <C-y>, <C-e> ; zt, zz, zb
 (pack :karb94/neoscroll.nvim {:config #((setup! :neoscroll)) :event :BufRead})
 ;; magit for neovim
 (pack :TimUntersberger/neogit
       {:dependencies [;; Single tabpage interface for easily cycling through diffs for all modified files for any git rev
                       :sindrets/diffview.nvim]
        :config #((setup! :neogit) {:integrations {:diffview true}})})
 ;; Flexible session management
 (pack :jedrzejboczar/possession.nvim
       {:dependencies [:nvim-lua/plenary.nvim]
        :config #((setup! :possession) {:autosave {:on_quit false}})})
 ;; Smart and powerful comment plugin for neovim
 (pack :numToStr/Comment.nvim {:config (fn []
                                         ((setup! :Comment))
                                         (let [ft (require :Comment.ft)]
                                           (ft.set "fennel" ";;%s")))})
 ;; autopairs
 (pack :m4xshen/autoclose.nvim
       {:config #((setup! :autoclose) {:keys {"'" {:close false}}})
        :event :InsertEnter})
 ;; Add/change/delete surrounding delimiter pairs with ease
 (pack :kylechui/nvim-surround {:config #((setup! :nvim-surround))
                                :event :BufRead})
 ;; Replace with regex
 (pack :nvim-pack/nvim-spectre {:lazy true :config #((setup! :spectre))})
 ;; A color highlighter
 (pack :norcalli/nvim-colorizer.lua
       {:config #((setup! :colorizer) [:css :scss] {:css true})
        :ft [:css :scss]})
 ;; highlight and search for todo comments
 (pack :folke/todo-comments.nvim
       {:config #((setup! :todo-comments)) :event :BufRead})
 ;; icons
 (pack :nvim-tree/nvim-web-devicons)
 ;; calculator
 (pack :Apeiros-46B/qalc.nvim {:cmd [:Qalc :QalcAttach]})]
 ;; Flow state reading in neovim
 ;; (pack :nullchilly/fsread.nvim {:cmd [:FSRead :FSClear :FSToggle]})]

