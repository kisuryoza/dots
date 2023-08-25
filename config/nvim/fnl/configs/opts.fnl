(import-macros {: set!} :macros)

(set! :clipboard "unnamedplus")
(set! :termguicolors true)

(set! :expandtab true)
(set! :tabstop 4)
(set! :shiftwidth 4)
(set! :shiftround true)
(set! :softtabstop 4)
(set! :smartindent true)

(set! :number true)
(set! :relativenumber true)
(set! :foldmethod "marker")
(set! :hlsearch true)
(set! :showmode false)
(set! :cursorline true)
(set! :scrolloff 2)
(set! :virtualedit "block")
(set! :wrap false)
(set! :timeoutlen 300)
(set! :ignorecase true)
(set! :smartcase true)
(set! :updatetime 300)
(set! :splitbelow true)
(set! :splitright true)

(set! :swapfile false)
(set! :undofile true)
(set! :undodir (.. (os.getenv "HOME") "/.cache/nvim/undo//"))
(set! :history 100)

(vim.opt.fillchars:append {:horiz "━"
                           :horizup "┻"
                           :horizdown "┳"
                           :vert "┃"
                           :vertleft "┨"
                           :vertright "┣"
                           :verthoriz "╋"})

