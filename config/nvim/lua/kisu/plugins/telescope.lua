local vk = vim.keymap

local M = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "echasnovski/mini.icons",
        "nvim-telescope/telescope-ui-select.nvim",
        -- "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
        { "<leader>fl", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        {
            "<leader>fg",
            function()
                local word = vim.fn.input("Grep > ")
                require("telescope.builtin").grep_string({ search = word })
            end,
            desc = "Grep word",
        },
        {
            "<leader>fw",
            function()
                local word = vim.fn.expand("<cword>")
                require("telescope.builtin").grep_string({ search = word })
            end,
            desc = "Grep curr word",
        },
        {
            "<leader>fW",
            function()
                local word = vim.fn.expand("<cWORD>")
                require("telescope.builtin").grep_string({ search = word })
            end,
            desc = "Grep curr WORD",
        },
    },
}

M.config = function()
    local telescope = require("telescope")
    telescope.setup({
        extensions = {
            fzy_native = {
                override_file_sorter = true,
                override_generic_sorter = false,
            },
        },
    })
    telescope.load_extension("ui-select")
    --[[ local trouble = require("trouble.providers.telescope")
    telescope.setup({
        defaults = {
            mappings = {
                i = { ["<c-t>"] = trouble.open_with_trouble },
                n = { ["<c-t>"] = trouble.open_with_trouble },
            },
        },
    }) ]]
end

return M
