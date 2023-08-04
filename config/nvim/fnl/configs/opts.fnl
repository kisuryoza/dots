(fn set-opts [opts]
  (for [i 1 (length opts) 2]
    (let [key (. opts i)
          value (. opts (+ i 1))]
      (tset vim.opt key value))))

(set-opts
  [:autoread true
   :shadafile "NONE"
   :clipboard "unnamedplus"
   :fileformat "unix"
   :guifont "JetBrains Mono:h10"
   :termguicolors true

   :autoindent true
   :expandtab true
   :tabstop 4
   :shiftwidth 4
   :shiftround true
   :softtabstop 4
   :smartindent true
   ;; :colorcolumn "80"

   :number true
   :relativenumber true
   :numberwidth 3
   :foldmethod "marker"
   :hlsearch true
   :showmode false

   :mouse "a"
   :updatetime 500
   :cursorline true
   :cursorlineopt "both"
   :scrolloff 2
   :whichwrap "[,]"
   :virtualedit "block"
   :conceallevel 0
   :concealcursor "nc"
   :wrap false

   :ignorecase true
   :smartcase true

   :splitbelow true
   :splitright true

   :shadafile ""
   :swapfile false
   :backup false
   :undofile true
   :undodir (.. (os.getenv "XDG_CACHE_HOME") "/nvim/undo//")
   :history 100])

(vim.opt.fillchars:append {:horiz "━"
                           :horizup "┻"
                           :horizdown "┳"
                           :vert "┃"
                           :vertleft "┨"
                           :vertright "┣"
                           :verthoriz "╋"})

(set vim.g.mapleader " ")
(set vim.g.maplocalleader "\\")
