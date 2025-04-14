return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        init = function()
            if os.getenv("TERM") ~= "linux" then vim.cmd("colorscheme catppuccin-mocha") end
        end,
        opts = {
            transparent_background = true,
            compile_path = (vim.fn.stdpath("cache") .. "/catppuccin"),
            custom_highlights = function(colors)
                return {
                    NormalFloat = { bg = colors.crust },
                }
            end,
            integrations = {
                neogit = true,
                treesitter_context = true,
                which_key = true,
            },
        },
    },
    -- {
    --     "rebelot/kanagawa.nvim",
    --     priority = 1000,
    --     init = function()
    --         if os.getenv("TERM") ~= "linux" then vim.cmd("colorscheme kanagawa-wave") end
    --     end,
    --     opts = {
    --         compile = true,
    --         transparent = true,
    --         colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
    --     },
    -- },

    require("kisu.plugins.dap"),
    require("kisu.plugins.treesitter"),
    require("kisu.plugins.telescope"),

    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                -- c = { "clangtidy" },
                -- cpp = { "clangtidy" },
                fish = { "fish" },
                lua = { "selene" },
                sh = { "shellcheck", "bash" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function() lint.try_lint() end,
            })
        end,
        event = "VeryLazy",
    },
    {
        "stevearc/conform.nvim",
        config = function()
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = {
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    lua = { "stylua" },
                    sh = { "shfmt", "shellharden" },
                    markdown = { "prettier" },
                    yaml = { "prettier" },
                    json = { "jq" },
                },
            })
            vim.keymap.set(
                "n",
                "<leader>bf",
                function() conform.format({ async = true, lsp_fallback = true }) end,
                { remap = true, desc = "Format buffer" }
            )
        end,
        event = "VeryLazy",
    },
    { "echasnovski/mini.surround", opts = {}, event = "VeryLazy" },
    -- { "echasnovski/mini.ai", opts = {}, event = "VeryLazy" },
    -- {
    --     -- in `~/.local/share/nvim/lazy/mini.completion/lua/mini/completion.lua:276` comment out `and item.kind ~= 15`
    --     "echasnovski/mini.completion", -- Completion and signature help
    --     opts = { lsp_completion = { source_func = "omnifunc", auto_setup = false }, fallback_action = function() end },
    --     event = "VeryLazy",
    -- },
    {
        "echasnovski/mini.icons",
        lazy = true,
        config = function()
            require("mini.icons").setup()
            MiniIcons.mock_nvim_web_devicons()
        end,
    },
    {
        "echasnovski/mini.hipatterns", -- Highlight patterns in text
        config = function()
            local hipatterns = require("mini.hipatterns")
            hipatterns.setup({
                highlighters = {
                    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
                    hex_color = hipatterns.gen_highlighter.hex_color(),
                },
            })
        end,
        event = "VeryLazy",
    },
    {
        -- motions allow to jump to any position in the visible editor area
        "ggandor/leap.nvim",
        dependencies = { { "ggandor/flit.nvim", opts = {} } },
        config = function() vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" }) end,
        event = "VeryLazy",
        keys = {
            { "s", "<Plug>(leap)", desc = "Leap" },
            { "gs", "<Plug>(leap-from-window)", desc = "Leap from window" },
        },
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "echasnovski/mini.icons" },
        opts = {
            columns = { "permissions", "size", "mtime" },
            delete_to_trash = true,
            keymaps = {
                ["H"] = { "actions.parent", mode = "n" },
                ["L"] = "actions.select",
            },
        },
        cmd = "Oil",
    },
    {
        "cbochs/grapple.nvim",
        dependencies = { "echasnovski/mini.icons" },
        opts = { scope = "git" },
        cmd = "Grapple",
        keys = {
            { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
            { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
            { "<C-k>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
            { "<C-j>", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            numhl = true,
            on_attach = function(bufnr)
                local vk = vim.keymap
                local gitsigns = require("gitsigns")
                vk.set("n", "<leader>gl", gitsigns.toggle_linehl, { buffer = bufnr, desc = "Highlight lines" })
                vk.set(
                    "n",
                    "<leader>gb",
                    gitsigns.toggle_current_line_blame,
                    { buffer = bufnr, desc = "Toggle line blame" }
                )
                vk.set("n", "<leader>ghr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
                vk.set("n", "<leader>ghP", gitsigns.preview_hunk_inline, { buffer = bufnr, desc = "Preview hunk" })
                vk.set("n", "<leader>ghp", gitsigns.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
                vk.set("n", "<leader>ghn", gitsigns.next_hunk, { buffer = bufnr, desc = "Next hunk" })
                vk.set("n", "<leader>ghs", gitsigns.select_hunk, { buffer = bufnr, desc = "Select hunk" })
            end,
        },
        event = "VeryLazy",
    },
    {
        -- Git interface
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "sindrets/diffview.nvim", opts = {}, cmd = { "DiffviewOpen", "DiffviewFileHistory" } },
        },
        opts = { integrations = { diffview = true } },
        cmd = "Neogit",
        keys = { { "<leader>gn", "<cmd>Neogit<cr>", desc = "Open Neogit" } },
    },
    { "folke/which-key.nvim", opts = { icons = { rules = false } } },
    {
        "mbbill/undotree",
        keys = { { "<leader>cu", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", desc = "Undotree" } },
    },
    -- {
    --     "OXY2DEV/markview.nvim",
    --     dependencies = {
    --         "nvim-treesitter/nvim-treesitter",
    --         "echasnovski/mini.icons",
    --     },
    --     lazy = false,
    -- },
    { "NStefan002/speedtyper.nvim", opts = {}, cmd = "Speedtyper" },
}
