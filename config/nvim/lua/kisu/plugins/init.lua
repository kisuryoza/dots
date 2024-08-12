return {
    require("kisu.plugins.colorscheme"),
    require("kisu.plugins.alpha"),

    require("kisu.plugins.lsp"),
    require("kisu.plugins.dap"),
    require("kisu.plugins.cmp"),

    require("kisu.plugins.treesitter"),
    require("kisu.plugins.telescope"),
    require("kisu.plugins.gitsigns"),
    require("kisu.plugins.crates"),

    {
        -- motions allow to jump to any position in the visible editor area
        "ggandor/leap.nvim",
        dependencies = {
            -- f/F/t/T motions on steroids
            { "ggandor/flit.nvim", opts = {} },
            -- remote operations on Vim's native text objects
            { "ggandor/leap-spooky.nvim", opts = {} },
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
        dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
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
        dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
        opts = {
            scope = "git",
        },
        cmd = "Grapple",
        keys = {
            { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
            { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
            { "<C-k>", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
            { "<C-j>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
        },
    },
    {
        -- Git interface
        "NeogitOrg/neogit",
        dependencies = {
            { "nvim-lua/plenary.nvim", lazy = true },
            { "sindrets/diffview.nvim", opts = {}, lazy = true },
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
        dependencies = { "nvim-lua/plenary.nvim", lazy = true },
        lazy = false,
        keys = {
            { "<leader>ct", "<cmd>TodoQuickFix<cr>", desc = "List of TODOs" },
        },
    },
    --[[ {
        -- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
        opts = {},
        cmd = "Trouble",
        keys = {
            "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        },
    }, ]]
    {
        -- Distraction-free coding
        "folke/zen-mode.nvim",
        -- dependencies = { "folke/twilight.nvim", lazy = true },
        opts = {},
        cmd = "ZenMode",
    },
    {
        -- Smart and powerful comment plugin for neovim
        "numToStr/Comment.nvim",
        opts = {},
        event = "VeryLazy",
    },
    {
        -- Add/change/delete surrounding delimiter pairs with ease
        "kylechui/nvim-surround",
        dependencies = { "nvim-treesitter/nvim-treesitter", lazy = true },
        opts = {},
        event = "VeryLazy",
    },
    {
        -- manage undos as a tree
        "jiaoshijie/undotree",
        dependencies = { "nvim-lua/plenary.nvim", lazy = true },
        opts = {},
        keys = {
            { "<leader>cu", "<cmd>lua require('undotree').toggle()<cr>", desc = "Undotree" },
        },
    },
    {
        -- A better annotation generator. Supports multiple languages and annotation conventions.
        "danymat/neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter", lazy = true },
        opts = { snippet_engine = "luasnip" },
        cmd = "Neogen",
    },
    {
        -- Practise typing
        "NStefan002/speedtyper.nvim",
        opts = {},
        cmd = "Speedtyper",
    },
}
