local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- {{{ opts
vim.o.pumblend = 15
vim.o.completeopt = "menuone,popup,noinsert,noselect"
-- vim.o.cmdheight = 0;

vim.o.expandtab = true
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.softtabstop = 4

vim.o.foldmethod = "marker"
vim.o.scrolloff = 2
vim.o.virtualedit = "block"
vim.o.wrap = false
vim.o.linebreak = true
vim.o.timeoutlen = 500
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.winborder = "single"

vim.o.mouse = ""
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.signcolumn = "yes"
vim.o.statuscolumn = "%l%s"

vim.o.swapfile = true
vim.o.undofile = true
vim.o.undodir = (os.getenv("HOME") .. "/.cache/nvim/undo//")
vim.o.history = 100
vim.o.grepprg = "rg --color=never --vimgrep --smart-case"
-- vim.o.path = ".,,/usr/include,/usr/include/**,"
-- vim.o.path = ".,,/usr/include,"

vim.lsp.log.set_level(vim.log.levels.OFF)
-- }}}

-- {{{ plugins
autocmd("PackChanged", {
    callback = function(args)
        local data = args.data
        if data.kind == "install" or data.kind == "update" then
            print("Installing...")

            if data.spec.name == "nvim-treesitter" then vim.cmd("TSUpdate") end
        end
    end,
})

vim.pack.add({
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/ggandor/leap.nvim",
    -- "https://github.com/cbochs/grapple.nvim",
    "https://github.com/echasnovski/mini.pick",
    "https://github.com/echasnovski/mini.surround",
    "https://github.com/echasnovski/mini.hipatterns",
    "https://github.com/tpope/vim-fugitive",
    -- "https://github.com/lewis6991/gitsigns.nvim",
    -- "https://github.com/mbbill/undotree",

    "https://github.com/nvim-treesitter/nvim-treesitter",

    -- "https://github.com/mfussenegger/nvim-lint",
    -- "https://github.com/mfussenegger/nvim-dap",
    -- "https://github.com/nvim-neotest/nvim-nio",
    -- { src = "https://github.com/rcarriga/nvim-dap-ui", version = "4.0.0" }, -- uses nvim-nio
    -- "https://github.com/theHamsta/nvim-dap-virtual-text",

    "https://github.com/NStefan002/speedtyper.nvim",
})

if os.getenv("TERM") ~= "linux" then -- tty
    require("rose-pine").setup({
        styles = { transparency = true },
        highlight_groups = {
            Text = { fg = "text" },
        },
    })
    vim.cmd("colorscheme rose-pine-moon")
else
    vim.cmd("colorscheme habamax")
end

require("oil").setup({
    columns = { "permissions", "size", "mtime" },
    delete_to_trash = true,
    keymaps = {
        ["H"] = { "actions.parent", mode = "n" },
        ["L"] = "actions.select",
    },
})

vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
-- Exclude whitespace and the middle of alphabetic words from preview
require("leap").opts.preview_filter = function(ch0, ch1, ch2)
    return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
end

-- require("grapple").setup({ scope = "cwd", icons = false })

require("mini.pick").setup({
    mappings = {
        move_down = "<C-j>",
        move_up = "<C-k>",
        choose_all = {
            char = "<C-q>",
            func = function()
                local mappings = MiniPick.get_picker_opts().mappings
                vim.api.nvim_input(mappings.mark_all .. mappings.choose_marked)
            end,
        },
    },
})

require("mini.surround").setup({
    mappings = {
        add = "ys",
        delete = "ds",
        find = "",
        find_left = "",
        highlight = "",
        replace = "cs",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
    },
    search_method = "cover_or_next",
})
-- Remap adding surrounding to Visual mode selection
vim.keymap.del("x", "ys")
map("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
-- Make special mapping for "add surrounding for line"
map("n", "yss", "ys_", { remap = true })

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
    highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})

-- "echasnovski/mini.completion"
-- -- in `~/.local/share/nvim/lazy/mini.completion/lua/mini/completion.lua:276` comment out `and item.kind ~= 15`

-- require("gitsigns").setup({
--     numhl = true,
--     on_attach = function(bufnr)
--         -- stylua: ignore start
--         map("n", "<leader>gl", ":Gitsigns toggle_linehl<CR>", { buffer = bufnr, desc = "Highlight lines" })
--         map("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { buffer = bufnr, desc = "Toggle line blame" })
--         map("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { buffer = bufnr, desc = "Reset hunk" })
--         map("n", "<leader>gP", ":Gitsigns preview_hunk_inline<CR>", { buffer = bufnr, desc = "Preview hunk" })
--         map("n", "<leader>gp", ":Gitsigns prev_hunk<CR>", { buffer = bufnr, desc = "Prev hunk" })
--         map("n", "<leader>gn", ":Gitsigns next_hunk<CR>", { buffer = bufnr, desc = "Next hunk" })
--         -- stylua: ignore end
--     end,
-- })

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "cpp",
        "zig",
        "rust",
        "bash",
        "glsl",
    },
    auto_install = false,
    highlight = {
        enable = true,
    },
})
-- }}}

-- {{{ keymaps
-- macro: format buffer using 'formatprg'
vim.fn.setreg("f", "mggogqG'g")

map("t", "<Esc>", vim.keycode("<C-\\><C-n>"), { desc = "Exit terminal mode" })
map("n", "<C-t>", ":tabnew<CR>")
map("i", "<C-j>", [[pumvisible() ? "<C-n>" : "<C-j>"]], { expr = true })
map("i", "<C-k>", [[pumvisible() ? "<C-p>" : "<C-k>"]], { expr = true })

map("n", "<leader>ec", ":e $MYVIMRC | :cd %:h<CR>")
map("n", "<leader>en", ":e ~/Sync/Notes/index.md | :cd %:h<CR>")
map("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Add diags to qflist" })
map("n", "<leader>bl", vim.diagnostic.setloclist, { desc = "Add buf diags to loclist" })
map("n", "<leader>od", function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end)
map("n", "<leader>bf", function() vim.lsp.buf.format({ async = true }) end)
map({ "n", "v" }, "<leader>y", '"+y')

map("n", "<leader>bb", ":Pick buffers<CR>")
map("n", "<leader>ff", ":Pick files<CR>")
map("n", "<leader>fg", ":Pick grep<CR>")
map("n", "<leader>fw", ":Pick grep pattern='<cword>'<CR>")
map("n", "<leader>fW", ":Pick grep pattern='<cWORD>'<CR>")

map("n", "s", "<Plug>(leap)", { desc = "Leap" })
map("v", "s", "<Plug>(leap)", { desc = "Leap" })
map("n", "gs", "<Plug>(leap-from-window)", { desc = "Leap from window" })

-- map("n", "<leader>u", ":UndotreeToggle<CR>:UndotreeFocus<CR>", { desc = "Undotree" })

-- map("n", "<leader>m", ":Grapple toggle<CR>", { desc = "Grapple toggle tag" })
-- map("n", "<leader>M", ":Grapple toggle_tags<CR>", { desc = "Grapple open tags window" })
-- map("n", "<C-k>", ":Grapple cycle_tags prev<CR>", { desc = "Grapple cycle previous tag" })
-- map("n", "<C-j>", ":Grapple cycle_tags next<CR>", { desc = "Grapple cycle next tag" })
-- }}}

-- {{{ status line
local function get_hl(name) return vim.api.nvim_get_hl(0, { name = name }) end
local function set_hl(name, fg_hl)
    local bg = get_hl("TabLine").bg
    vim.api.nvim_set_hl(0, name, { fg = fg_hl, bg = bg })
end
set_hl("sl_active", get_hl("Text").fg)
set_hl("sl_notactive", get_hl("Comment").fg)
set_hl("sl_diagError", get_hl("DiagnosticError").fg)

function _G.slLsp()
    local label = {}

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        for _, client in ipairs(clients) do
            table.insert(label, client.name)
        end
    end

    local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if #errors ~= 0 then table.insert(label, " %#sl_diagError# " .. #errors .. "%*") end

    return table.concat(label)
end

autocmd({ "WinEnter", "BufWinEnter" }, {
    pattern = "*",
    callback = function()
        vim.opt_local.statusline =
        "%<%#sl_active#%f %h%w%m%r%=%{%v:lua._G.slLsp()%} %#sl_active#%l/%L,%c %P %Y %{ &fenc!='utf-8'?&fenc..' ':'' }%{% &ff!='unix'?&ff..' ':'' %}"
    end,
})

autocmd("WinLeave", {
    pattern = "*",
    callback = function()
        vim.opt_local.statusline =
        "%<%#sl_notactive#%f %h%w%m%r%=%{%v:lua._G.slLsp()%} %#sl_notactive#%l/%L,%c %P %Y %{ &fenc!='utf-8'?&fenc..' ':'' }%{% &ff!='unix'?&ff..' ':'' %}"
    end,
})
-- }}}

-- {{{ auto/commands
---@param trigger string
---@param body string|function
---@param opts? vim.keymap.set.Opts
function _G.addSnippet(trigger, body, opts)
    map("ia", trigger, function()
        -- If abbrev is expanded with keys like "(", ")", "<CR>", "<space>",
        -- don't expand the snippet. Only accept "<c-]>" as a trigger key.
        local c = vim.fn.nr2char(vim.fn.getchar(0))
        if c ~= "" then
            vim.api.nvim_feedkeys(trigger .. c, "i", true)
            return
        end
        if type(body) == "function" then body = body() end
        vim.snippet.expand(body)
    end, opts)
end

vim.api.nvim_create_user_command(
    "Scratch",
    function()
        vim.cmd([[
        split
        enew
        file scratch
        set bufhidden=delete
    ]])
    end,
    {}
)

autocmd(
    "FileType",
    { pattern = "sh", callback = function() vim.bo.formatprg = "shfmt -i 4 | shellharden --transform ''" end }
)
autocmd("FileType", { pattern = "lua", callback = function() vim.bo.formatprg = "stylua -" end })
autocmd("FileType", { pattern = "glsl", callback = function() vim.bo.formatprg = "clang-format" end })
autocmd("FileType", { pattern = "markdown", callback = function() vim.bo.formatprg = "prettier --parser markdown" end })
autocmd("FileType", { pattern = "css", callback = function() vim.bo.formatprg = "prettier --parser css" end })
autocmd("FileType", { pattern = "json", callback = function() vim.bo.formatprg = "jq" end })

autocmd("BufWritePre", {
    pattern = "*",
    desc = "Deletes trailing spaces and replaces tabs w/ spaces on save",
    callback = function()
        if vim.o.binary then return nil end
        local winview = vim.fn.winsaveview
        vim.cmd("keeppatterns %s/\\s\\+$//e")
        if vim.fn.tolower(vim.fn.expand("%:t")) ~= "makefile" then vim.cmd("retab") end
        vim.fn.winrestview(winview())
    end,
})
-- }}}

-- {{{ welcome screen
local augrp = vim.api.nvim_create_augroup("welcome_screen", { clear = true })
local function openWelcomeScreen()
    local welcome = {
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⣶⣶⣶⣶⣶⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⢀⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⢿⣿⣿⣿⣿⡏⠈⠛⢿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠈⢹⣿⢷⣢⡀⠀⢙⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠁⠀⣸⣿⣦⣼⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠠⣶⣤⣤⣤⣄⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⣀⣴⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠈⢹⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠉⠉⠉⠁⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠻⣿⣿⣿⣿⣿⣿⣶⣶⣤⣤⣶⡶⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠉⠛⠿⠿⠿⠿⠿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠴⠜⠊⠛⠒⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡔⠁⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⡟⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣾⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣵⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣾⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣤⣀⣀⣀⣀⣀⡀⠀⣀⣠⣼⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⢿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠛⠿⠿⠿⠿⠿⠿⠿⠿⠿⠛⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    }
    local text = "Well are those who rise in the early morn, while those late to bed I shall forewarn"
    vim.cmd("enew")
    local bufn = vim.api.nvim_get_current_buf()
    -- local bufn = vim.api.nvim_create_buf(false, true)
    -- vim.api.nvim_set_current_buf(bufn)
    local showtabline = vim.o.showtabline
    local laststatus = vim.o.laststatus
    autocmd("BufLeave", {
        group = augrp,
        buffer = bufn,
        callback = function()
            if vim.o.cmdheight > 0 then vim.cmd("echo ''") end
            vim.o.showtabline = showtabline
            vim.o.laststatus = laststatus
            vim.api.nvim_del_augroup_by_id(augrp)
        end,
    })

    vim.api.nvim_buf_set_lines(bufn, 0, -1, false, welcome)
    vim.api.nvim_buf_set_lines(bufn, #welcome, -1, false, { text })
    local options = {
        "bufhidden=wipe",
        "colorcolumn=",
        "foldcolumn=0",
        "matchpairs=",
        "nobuflisted",
        "nocursorcolumn",
        "nocursorline",
        "nolist",
        "nonumber",
        "noreadonly",
        "norelativenumber",
        "nospell",
        "noswapfile",
        "signcolumn=no",
        "statuscolumn=",
        "synmaxcol&",
        "buftype=nofile",
        "nomodeline",
        "nomodifiable",
        "foldlevel=999",
        "nowrap",
        "showtabline=1",
        "laststatus=1",
    }
    vim.cmd(("silent! noautocmd setlocal %s"):format(table.concat(options, " ")))
end

autocmd("VimEnter", {
    group = augrp,
    callback = function()
        if vim.fn.argc() > 0 then return end
        if #vim.api.nvim_list_bufs() > 1 then return end
        if vim.bo.filetype ~= "" then return end
        openWelcomeScreen()
    end,
})
-- }}}

require("kisu.lsp")
-- require("kisu.dap")
