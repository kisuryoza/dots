--[[ ---@param findstart number
---@param base string
function comletionfunc(findstart, base)
    -- if findstart == 1 then
    --     return 0
    -- end
    -- local matches = { "aaa", "bbb", "ccc" }
    -- if string.len(base) == 0 then
    --     return matches
    -- end
    -- print(base)
    local a = vim.lsp.completion._omnifunc(findstart, base)
    print()
    print(vim.inspect(a))
    return a
end
vim.o.completefunc = "v:lua.comletionfunc" ]]

vim.o.pumblend = 15
vim.o.completeopt = "menuone,popup,noinsert,noselect"
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

vim.o.swapfile = true
vim.o.undofile = true
vim.o.undodir = (os.getenv("HOME") .. "/.cache/nvim/undo//")
vim.o.history = 100
vim.o.grepprg = "rg --color=never --vimgrep --smart-case"

vim.opt.fillchars:append({
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┨",
    vertright = "┣",
    verthoriz = "╋",
    diff = "󰿟",
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
