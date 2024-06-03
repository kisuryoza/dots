local vk = vim.keymap

return {
    require("kisu.plugins.colorscheme"),
    require("kisu.plugins.alpha"),

    require("kisu.plugins.lsp"),
    require("kisu.plugins.dap"),
    require("kisu.plugins.cmp"),
    require("kisu.plugins.leap"),
    require("kisu.plugins.treesitter"),

    require("kisu.plugins.telescope"),
    require("kisu.plugins.harpoon"),

    require("kisu.plugins.gitsigns"),
    require("kisu.plugins.crates"),
    {
        -- file explorer
        "TheBlob42/drex.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            local conf, setup = require("drex.config"), {}
            setup.hide_cursor = false
            setup.actions = { files = { delete_cmd = ((vim.fn.executable("trash") == 1) and "trash") } }
            conf.configure(setup)
        end,
    },
    {
        -- Git interface
        "NeogitOrg/neogit",
        dependencies = { "nvim-lua/plenary.nvim", { "sindrets/diffview.nvim", config = true } },
        event = "VeryLazy",
        config = function()
            local neogit = require("neogit")
            vk.set("n", "<leader>gn", neogit.open, { desc = "Open Neogit" })
            neogit.setup({ integrations = { diffview = true } })
        end,
    },
    {
        -- popup with possible key bindings
        "folke/which-key.nvim",
        config = true,
    },
    {
        -- highlight and search for todo comments
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
            local todo_comments = require("todo-comments")
            vk.set("n", "<leader>ct", "<cmd>TodoQuickFix<CR>", { desc = "List of TODOs" })
            todo_comments.setup()
        end,
    },
    --[[ {
        -- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            local trouble = require("trouble")
            vim.keymap.set("n", "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
            trouble.setup()
        end,
    }, ]]
    {
        -- Distraction-free coding
        "folke/zen-mode.nvim",
        -- dependencies = { "folke/twilight.nvim" },
        cmd = "ZenMode",
        config = true,
    },
    {
        -- Smart and powerful comment plugin for neovim
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = true,
    },
    {
        -- autopairs
        "m4xshen/autoclose.nvim",
        event = "VeryLazy",
        opts = { keys = { ["'"] = { close = false } } },
    },
    {
        -- Add/change/delete surrounding delimiter pairs with ease
        "kylechui/nvim-surround",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "VeryLazy",
        config = true,
    },
    {
        -- manage undos as a tree
        "jiaoshijie/undotree",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
            local undotree = require("undotree")
            undotree.setup()
            vk.set("n", "<leader>cu", undotree.toggle, { desc = "Undotree" })
        end,
    },
    {
        -- A better annotation generator. Supports multiple languages and annotation conventions.
        "danymat/neogen",
        cmd = "Neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = { snippet_engine = "luasnip" },
    },
    {
        -- Practise typing
        "NStefan002/speedtyper.nvim",
        cmd = "Speedtyper",
        config = true,
    },
}
