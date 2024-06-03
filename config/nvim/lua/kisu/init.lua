vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.api.nvim_create_augroup("kisu", { clear = true })

local lazy = require("lazy")
local plugins = require("kisu.plugins")
lazy.setup(plugins, {
    lockfile = (vim.fn.stdpath("data") .. "/lazy-lock.json"),
    performance = {
        cache = { enabled = true },
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "tarPlugin",
                "tohtml",
                "tutor",
            },
        },
    },
})

require("kisu.opts")
require("kisu.key_maps")
require("kisu.statusline").setup()

local function byte2hex()
    vim.cmd("%! xxd -g 1 -u")
    vim.b.hex_ft = vim.bo.filetype
    vim.opt_local.binary = true
    vim.bo.filetype = "xxd"
end

local function hex2byte()
    vim.cmd("%! xxd -r")
    vim.bo.filetype = vim.b.hex_ft
    vim.opt_local.binary = false
end

vim.api.nvim_create_user_command("HexEdit", byte2hex, {})
vim.api.nvim_create_user_command("Hex2Byte", hex2byte, {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = "kisu",
    pattern = { "*" },
    desc = "Deletes trailing spaces and replaces tabs w/ spaces on save",
    callback = function()
        if vim.o.binary then
            return nil
        end
        local winview = vim.fn.winsaveview
        vim.cmd("keeppatterns %s/\\s\\+$//e")
        if vim.fn.tolower(vim.fn.expand("%:t")) ~= "makefile" then
            vim.cmd("retab")
        end
        vim.fn.winrestview(winview())
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = "kisu",
    pattern = { "*" },
    desc = "Reload file for changes",
    command = "checktime",
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = "kisu",
    pattern = "*",
    desc = "Open file at the last position it was edited earlier",
    command = 'silent! normal! g`"zv',
})
