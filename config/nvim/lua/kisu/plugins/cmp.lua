local vk = vim.keymap

local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

local M = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        -- "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
        -- "FelipeLema/cmp-async-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
    },
    event = "VeryLazy",
}

M.config = function()
    vim.opt.completeopt = "menu,menuone,noselect"
    local cmp, setup = require("cmp"), {}

    local luasnip = require("luasnip")
    require("luasnip.loaders.from_vscode").lazy_load()
    luasnip.setup({
        update_events = { "TextChanged", "TextChangedI" },
        region_check_events = { "CursorMoved", "CursorMovedI" },
        delete_check_events = { "TextChanged", "TextChangedI" },
        history = true,
    })
    vk.set("i", "<C-K>", luasnip.expand)
    vk.set({ "i", "s" }, "<C-L>", function()
        if luasnip.locally_jumpable(1) then
            luasnip.jump(1)
        end
    end)
    vk.set({ "i", "s" }, "<C-J>", function()
        if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
        end
    end)
    vk.set({ "i", "s" }, "<C-E>", function()
        if luasnip.choice_active() then
            luasnip.change_choice(1)
        end
    end)

    setup.snippet = {
        expand = function(args)
            -- return vim.snippet.expand(args.body)
            return luasnip.lsp_expand(args.body)
        end,
    }

    setup.mapping = {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if not entry then
                    cmp.select_next_item({
                        behavior = cmp.SelectBehavior.Select,
                    })
                else
                    cmp.confirm()
                end
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s", "c" }),
    }
    setup.sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }) --{ { name = "async_path" }, { name = "buffer" } }

    setup.window = { completion = { col_offset = -3 } }
    setup.formatting = {
        format = function(_entry, vim_item)
            --[[ if vim_item.menu ~= nil then
                vim_item.menu = string.sub(vim_item.menu, 1, 25)
            end ]]
            local kind = vim_item.kind
            local icon = kind_icons[kind]
            if icon ~= nil then
                vim_item.kind = ("" .. icon .. " ")
            else
                vim_item.kind = "  "
            end
            return vim_item
        end,
        fields = { "kind", "abbr", "menu" },
    }

    cmp.setup(setup)

    cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "nvim_lsp_document_symbol" },
            -- { name = "buffer" },
        }),
    })
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(--[[ { { name = "async_path" } }, ]] { { name = "cmdline" } }),
    })
end

return M
