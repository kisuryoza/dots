local M = {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
    },
    build = ":TSUpdate",
    event = "VeryLazy",
}

M.config = function()
    local treesitter, setup = require("nvim-treesitter.configs"), {}
    setup = {
        ensure_installed = {
            "rust",
            "c",
            "cpp",
            "bash",
            "lua",
            "markdown",
            "markdown_inline",
            "html",
            "diff",
        },
        auto_install = true,
        highlight = {
            enable = true,
            disable = function(_lang, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        },
        -- incremental_selection = {
        --     enable = true,
        --     keymaps = {
        --         init_selection = "<CR>",
        --         node_incremental = "<CR>",
        --         scope_incremental = "<S-CR>",
        --         node_decremental = "<BS>",
        --     },
        -- },
    }
    treesitter.setup(setup)
end

return M
