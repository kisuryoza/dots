return {
    require("kisu.plugins.colorscheme"),
    require("kisu.plugins.alpha"),

    require("kisu.plugins.lsp"),
    require("kisu.plugins.dap"),
    -- require("kisu.plugins.cmp"),

    require("kisu.plugins.treesitter"),
    require("kisu.plugins.telescope"),
    require("kisu.plugins.gitsigns"),

    {
        "echasnovski/mini.surround", -- Surround actions
        version = false,
        opts = {},
        event = "VeryLazy",
    },
    {
        "echasnovski/mini.comment", -- Comment lines
        version = false,
        opts = {},
        event = "VeryLazy",
    },
    {
        "echasnovski/mini.completion", -- Completion and signature help
        version = false,
        opts = { lsp_completion = { source_func = "omnifunc", auto_setup = false }, fallback_action = function() end },
        event = "VeryLazy",
    },
    -- { "echasnovski/mini.snippets", version = false, opts = {} },
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
        version = false,
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
        dependencies = {
            -- f/F/t/T motions on steroids
            { "ggandor/flit.nvim", opts = {} },
            -- remote operations on Vim's native text objects
            -- { "ggandor/leap-spooky.nvim", opts = {} },
        },
        config = function()
            vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
        end,
        event = "VeryLazy",
        keys = {
            { "<CR>", "<Plug>(leap)", desc = "Leap forward" },
            { "gs", "<Plug>(leap-from-window)", desc = "Leap from window" },
        },
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "echasnovski/mini.icons" },
        opts = {
            columns = {
                "icon",
                "permissions",
                "size",
                "mtime",
            },
            delete_to_trash = true,
        },
        cmd = "Oil",
    },
    {
        "cbochs/grapple.nvim",
        dependencies = { "echasnovski/mini.icons" },
        opts = {
            scope = "git",
        },
        cmd = "Grapple",
        keys = {
            { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
            { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
            { "<C-k>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
            { "<C-j>", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
        },
    },
    {
        -- Git interface
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "sindrets/diffview.nvim", opts = {}, cmd = { "DiffviewOpen", "DiffviewFileHistory" } },
        },
        opts = {
            integrations = { diffview = true },
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gn", "<cmd>Neogit<cr>", desc = "Open Neogit" },
        },
    },
    {
        -- popup with possible key bindings
        "folke/which-key.nvim",
        opts = { icons = { rules = false } },
    },
    --[[ {
        -- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
        "folke/trouble.nvim",
        dependencies = { "echasnovski/mini.icons" },
        opts = {},
        cmd = "Trouble",
        keys = {
            { "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        },
    }, ]]
    {
        -- manage undos as a tree
        "jiaoshijie/undotree",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        keys = { { "<leader>cu", "<cmd>lua require('undotree').toggle()<cr>", desc = "Undotree" } },
    },
    {
        "OXY2DEV/markview.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "echasnovski/mini.icons",
        },
        lazy = false,
    },
    {
        "saecki/crates.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            lsp = {
                enabled = true,
                on_attach = function(_client, bufnr)
                    vim.keymap.set(
                        "n",
                        "<leader>Cf",
                        "<cmd>Crates show_features_popup<cr>",
                        { buffer = bufnr, desc = "Crates: Features" }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>Cd",
                        "<cmd>Crates show_dependencies_popup<cr>",
                        { buffer = bufnr, desc = "Crates: Dependencies" }
                    )
                end,
                actions = true,
                completion = true,
                hover = true,
            },
        },
        event = "BufRead Cargo.toml",
    },
    {
        "epwalsh/obsidian.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        opts = {
            ui = { enable = false },
            daily_notes = {
                folder = "daily",
            },
            workspaces = {
                {
                    name = "notes",
                    path = "~/Sync/Notes",
                },
            },
        },
        event = "BufRead " .. vim.fn.expand("~/Sync/Notes/index.md"),
    },
    {
        -- Practise typing
        "NStefan002/speedtyper.nvim",
        opts = {},
        cmd = "Speedtyper",
    },
}
