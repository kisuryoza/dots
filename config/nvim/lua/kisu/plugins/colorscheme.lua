return {
    {
        "catppuccin/nvim",
        priority = 1000,
        name = "catppuccin",
        init = function()
            if os.getenv("TERM") ~= "linux" then
                vim.cmd("colorscheme catppuccin-mocha")
            end
        end,
        opts = {
            transparent_background = true,
            dim_inactive = { enabled = true },
            compile_path = (vim.fn.stdpath("cache") .. "/catppuccin"),
            integrations = {
                harpoon = true,
                leap = true,
                neogit = true,
                treesitter_context = true,
                lsp_trouble = true,
                which_key = true,
                fidget = true,
            },
        },
    },
    --[[ {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        init = function()
            if os.getenv("TERM") ~= "linux" then
                vim.cmd("colorscheme kanagawa-wave")
            end
        end,
        opts = {
            compile = true,
            transparent = true,
            dimInactive = true,
            colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
        },
    }, ]]
}
