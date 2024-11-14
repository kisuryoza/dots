local M = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-cmdline",
    },
    event = "VeryLazy",
}

M.config = function()
    local cmp, setup = require("cmp"), {}

    setup.snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    }
    setup.mapping = {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- ["<C-k>"] = cmp.mapping.select_prev_item(),
        -- ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if entry then
                -- if not entry then
                --     cmp.select_next_item({
                --         behavior = cmp.SelectBehavior.Select,
                --     })
                -- else
                    cmp.confirm()
                end
            else
                fallback()
            end
        end, { "i", "s" }),
    }
    setup.sources = cmp.config.sources({
        { name = "nvim_lsp" },
    })
    setup.window = { completion = { col_offset = -3 } }

    cmp.setup(setup)

    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "cmdline" } }),
    })
end

return M
