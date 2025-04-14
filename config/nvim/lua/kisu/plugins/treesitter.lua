local M = {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-refactor",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    event = "VeryLazy",
}

M.config = function()
    local treesitter, setup = require("nvim-treesitter.configs"), {}
    setup = {
        ensure_installed = {
            "c",
            "cpp",
            "zig",
            "rust",
            "bash",
            "lua",
            "markdown",
            "markdown_inline",
            "diff",
        },
        auto_install = false,
        highlight = {
            enable = true,
            -- disable = function(_lang, buf)
            --     local max_filesize = 100 * 1024 -- 100 KB
            --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            --     if ok and stats and stats.size > max_filesize then return true end
            -- end,
        },
        refactor = {
            smart_rename = {
                enable = true,
                keymaps = {
                    smart_rename = "grn",
                },
            },
            navigation = {
                enable = true,
                keymaps = {
                    goto_definition = "grd",
                    list_definitions = false,
                    list_definitions_toc = false,
                    goto_next_usage = false,
                    goto_previous_usage = false,
                },
            },
        },
    }
    setup.textobjects = {
        select = {
            enable = true,
            lookahead = true,
            -- include_surrounding_whitespace = true,
            keymaps = {
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        swap = {
            enable = true,
            swap_next = { ["grs"] = "@parameter.inner" },
            swap_previous = { ["grS"] = "@parameter.inner" },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = { query = "@class.outer", desc = "Class start" },
                ["]s"] = { query = "@statement.outer", desc = "Statement" },
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = { query = "@class.outer", desc = "Class end" },
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = { query = "@class.outer", desc = "Class start" },
                ["[s"] = { query = "@statement.outer", desc = "Statement" },
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = { query = "@class.outer", desc = "Class end" },
            },
        },
    }

    treesitter.setup(setup)
end

return M
