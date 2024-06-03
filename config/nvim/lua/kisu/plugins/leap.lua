local vk = vim.keymap

local M = {
    "ggandor/leap.nvim",
    dependencies = {
        -- f/F/t/T motions on steroids
        { "ggandor/flit.nvim", config = true },
        -- remote operations on Vim's native text objects
        { "ggandor/leap-spooky.nvim", config = true },
    },
    event = "VeryLazy",
}

M.config = function()
    vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
    vk.set("n", "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
    vk.set("n", "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
    vk.set("n", "gs", "<Plug>(leap-from-window)", { desc = "Leap from window" })
end

return M
