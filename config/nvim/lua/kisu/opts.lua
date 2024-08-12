vim.o.completeopt = "menu,menuone,popup,noselect"
vim.o.clipboard = "unnamedplus"
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.shiftround = true
vim.o.softtabstop = 4
vim.o.smartindent = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.foldmethod = "marker"
vim.o.hlsearch = true
vim.o.showmode = false
vim.o.cursorline = true
vim.o.scrolloff = 2
vim.o.virtualedit = "block"
vim.o.wrap = false
vim.o.timeoutlen = 300
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 300
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mousemodel = "extend"

vim.o.swapfile = true
vim.o.undofile = true
vim.o.undodir = (os.getenv("HOME") .. "/.cache/nvim/undo//")
vim.o.history = 100
vim.o.grepprg = "rg --color=never --vimgrep --smart-case";

vim.o.fillchars = "horiz:━,horizdown:┳,horizup:┻,vert:┃,verthoriz:╋,vertleft:┨,vertright:┣"

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
        },
    },
})
