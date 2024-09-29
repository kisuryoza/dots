return {
    require("kisu.plugins.colorscheme"),
    require("kisu.plugins.alpha"),

    require("kisu.plugins.lsp"),
    require("kisu.plugins.dap"),
    require("kisu.plugins.cmp"),

    require("kisu.plugins.treesitter"),
    require("kisu.plugins.telescope"),
    require("kisu.plugins.gitsigns"),

    {
        "echasnovski/mini.icons",
        lazy = true,
        config = function()
            require("mini.icons").setup()
            MiniIcons.mock_nvim_web_devicons()
        end,
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
            { "s", "<Plug>(leap-forward)", desc = "Leap forward" },
            { "S", "<Plug>(leap-backward)", desc = "Leap backward" },
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
    {
        -- highlight and search for todo comments
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        event = "VeryLazy",
        keys = { { "<leader>ct", "<cmd>TodoQuickFix<cr>", desc = "List of TODOs" } },
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
        -- Smart and powerful comment plugin for neovim
        "numToStr/Comment.nvim",
        opts = {},
        event = "VeryLazy",
    },
    {
        -- Add/change/delete surrounding delimiter pairs with ease
        "kylechui/nvim-surround",
        opts = {},
        event = "VeryLazy",
    },
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
        ft = "markdown",
        -- event = "VeryLazy",
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
