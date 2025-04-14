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
-- vim.o.cmdheight = 0;

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.shiftround = true
vim.o.softtabstop = 4
vim.o.smartindent = true

vim.o.clipboard = "unnamedplus"
vim.o.foldmethod = "marker"
vim.o.showmode = false
vim.o.cursorline = true
vim.o.scrolloff = 2
vim.o.virtualedit = "block"
vim.o.wrap = false
vim.o.timeoutlen = 300
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.signcolumn = "yes:1"
vim.o.statuscolumn = "%l%s"

vim.o.swapfile = true
vim.o.undofile = true
vim.o.undodir = (os.getenv("HOME") .. "/.cache/nvim/undo//")
vim.o.history = 100
vim.o.grepprg = "rg --color=never --vimgrep --smart-case"

vim.lsp.set_log_level(vim.log.levels.OFF)

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
    virtual_text = true,
    severity_sort = true,
    jump = { float = true },
    signs = {
        text = {
            -- [vim.diagnostic.severity.ERROR] = " ",
            -- [vim.diagnostic.severity.WARN] = " ",
            -- [vim.diagnostic.severity.INFO] = " ",
            -- [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
})
