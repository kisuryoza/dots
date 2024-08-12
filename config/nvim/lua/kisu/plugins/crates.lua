local vk = vim.keymap

local function on_attach(_client, bufnr)
    local crates = require("crates")
    vk.set("n", "<leader>Cp", crates.show_popup, { buffer = bufnr, desc = "Crates: Show popup" })
    vk.set("n", "<leader>Cf", crates.show_features_popup, { buffer = bufnr, desc = "Crates: Features" })
    vk.set("n", "<leader>Cd", crates.show_dependencies_popup, { buffer = bufnr, desc = "Crates: Dependencies" })
end

local M = {
    "saecki/crates.nvim",
    dependencies = { "nvim-lua/plenary.nvim", lazy = true },
    opts = {
        lsp = {
            enabled = true,
            on_attach = on_attach,
            actions = true,
            completion = true,
            hover = true,
        },
    },
    event = "BufRead Cargo.toml",
}

return M
