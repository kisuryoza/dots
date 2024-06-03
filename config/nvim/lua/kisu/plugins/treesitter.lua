local M = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-refactor",
        "nvim-treesitter/nvim-treesitter-context",
    },
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
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",
                node_incremental = "<CR>",
                scope_incremental = "<S-CR>",
                node_decremental = "<BS>",
            },
        },
    }
    setup.textobjects = {
        enable = true,
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                aa = {
                    query = "@parameter.outer",
                    desc = "Outer part of parameter",
                },
                ia = {
                    query = "@parameter.inner",
                    desc = "Inner part of parameter",
                },
                af = {
                    query = "@function.outer",
                    desc = "Outer part of func",
                },
                ["if"] = {
                    query = "@function.inner",
                    desc = "Inner part of func",
                },
                ac = {
                    query = "@class.outer",
                    desc = "Outer part of class",
                },
                ic = {
                    query = "@class.inner",
                    desc = "Inner part of class",
                },
            },
        },
        swap = {
            enable = true,
            swap_next = { ["<leader>csn"] = "@parameter.inner" },
            swap_previous = { ["<leader>csp"] = "@parameter.inner" },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]m"] = {
                    query = "@function.outer",
                    desc = "Next func start",
                },
                ["]]"] = {
                    query = "@class.outer",
                    desc = "Next class start",
                },
                ["]s"] = {
                    query = "@statement.outer",
                    desc = "Next statement",
                },
            },
            goto_next_end = {
                ["]M"] = {
                    query = "@function.outer",
                    desc = "Next func end",
                },
                ["]["] = { query = "@class.outer", desc = "Next class end" },
            },
            goto_previous_start = {
                ["[m"] = {
                    query = "@function.outer",
                    desc = "Prev func start",
                },
                ["[["] = {
                    query = "@class.outer",
                    desc = "Prev class start",
                },
                ["[s"] = {
                    query = "@statement.outer",
                    desc = "Prev statement",
                },
            },
            goto_previous_end = {
                ["[M"] = {
                    query = "@function.outer",
                    desc = "Prev func end",
                },
                ["[]"] = { query = "@class.outer", desc = "Prev class end" },
            },
        },
    }
    setup.refactor = {
        highlight_definitions = {
            enable = true,
        },
    }
    treesitter.setup(setup)
end

return M
