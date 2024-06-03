vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.foldmethod = "marker"
vim.opt.hlsearch = true
vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.scrolloff = 2
vim.opt.virtualedit = "block"
vim.opt.wrap = false
vim.opt.timeoutlen = 300
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 300
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mousemodel = "extend"

vim.opt.swapfile = true
vim.opt.undofile = true
vim.opt.undodir = (os.getenv("HOME") .. "/.cache/nvim/undo//")
vim.opt.history = 100
vim.opt.grepprg = "rg --color=never --vimgrep --smart-case";

(vim.opt.fillchars):append({
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┨",
    vertright = "┣",
    verthoriz = "╋",
})

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
