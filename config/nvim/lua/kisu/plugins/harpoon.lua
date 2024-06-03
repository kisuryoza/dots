local vk = vim.keymap

local M = {
    "ThePrimeagen/harpoon",
    pin = true,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
}

M.config = function()
    local harpoon = require("harpoon")
    local telescope = require("telescope")
    telescope.load_extension("harpoon")
    harpoon:setup()

    -- stylua: ignore start
    vk.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add file to Harpoon" })
    vk.set("n", "<leader>H", function() (harpoon.ui):toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon open" })
    vk.set("n", "<C-k>", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
    vk.set("n", "<C-j>", function() harpoon:list():next() end, { desc = "Harpoon next" })
    vk.set("n", "<leader>ht", "<cmd>Telescope harpoon marks<CR>", { desc = "Harpoon telescope" })
    vk.set("n", "<leader>hq", function() harpoon:list():select(1) end, { desc = "Navig 1" })
    vk.set("n", "<leader>hw", function() harpoon:list():select(2) end, { desc = "Navig 2" })
    vk.set("n", "<leader>he", function() harpoon:list():select(3) end, { desc = "Navig 3" })
    vk.set("n", "<leader>hr", function() harpoon:list():select(4) end, { desc = "Navig 4" })
    -- stylua: ignore end
end

return M
