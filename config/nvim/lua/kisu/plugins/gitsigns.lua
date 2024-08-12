local vk = vim.keymap

local function on_attach(bufnr)
    local gitsigns = require("gitsigns")
    vk.set("n", "<leader>gl", gitsigns.toggle_linehl, { buffer = bufnr, desc = "Highlight lines" })
    vk.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle line blame" })
    vk.set("n", "<leader>ghr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
    vk.set("n", "<leader>ghP", gitsigns.preview_hunk_inline, { buffer = bufnr, desc = "Preview hunk" })
    vk.set("n", "<leader>ghp", gitsigns.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
    vk.set("n", "<leader>ghn", gitsigns.next_hunk, { buffer = bufnr, desc = "Next hunk" })
    vk.set("n", "<leader>ghs", gitsigns.select_hunk, { buffer = bufnr, desc = "Select hunk" })
end

local M = { "lewis6991/gitsigns.nvim", opts = { numhl = true, on_attach = on_attach }, event = "VeryLazy" }

return M
