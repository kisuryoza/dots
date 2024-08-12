local vk = vim.keymap

local M = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim", lazy = true },
        { "nvim-tree/nvim-web-devicons", lazy = true },
        { "nvim-telescope/telescope-ui-select.nvim", lazy = true },
    },
    event = "VeryLazy",
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

    local builtin = require("telescope.builtin")
    vk.set("n", "<leader>bb", builtin.buffers, { desc = "Buffers" })
    vk.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
    vk.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent" })
    vk.set("n", "<leader>fl", builtin.live_grep, { desc = "Live grep" })
    vk.set("n", "<leader>fg", function()
        local word = vim.fn.input("Grep > ")
        builtin.grep_string({ search = word })
    end, { desc = "Grep word" })
    vk.set("n", "<leader>fw", function()
        local word = vim.fn.expand("<cword>")
        builtin.grep_string({ search = word })
    end, { desc = "Grep curr word" })
    vk.set("n", "<leader>fW", function()
        local word = vim.fn.expand("<cWORD>")
        builtin.grep_string({ search = word })
    end, { desc = "Grep curr WORD" })
end

return M
