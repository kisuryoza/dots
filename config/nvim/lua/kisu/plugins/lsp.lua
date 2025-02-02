local vk = vim.keymap

local function lsp_completion(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local methods = vim.lsp.protocol.Methods
    if not client.supports_method(methods.textDocument_completion) then
        return
    end

    vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = false,
    })

    local function feedkeys(key)
        vim.api.nvim_feedkeys(vim.keycode(key), "n", true)
    end

    local function pumvisible()
        return tonumber(vim.fn.pumvisible()) ~= 0
    end

    -- same with <C-x><C-o>
    --[[ vk.set("i", "<C-x><C-j>", function()
        vim.lsp.completion.trigger()
    end, { buffer = bufnr, desc = "" }) ]]

    vk.set("i", "<Tab>", function()
        if pumvisible() then
            feedkeys("<C-y>")
        elseif vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
        else
            feedkeys("<Tab>")
        end
    end, { buffer = bufnr, desc = "" })

    vk.set("i", "<S-Tab>", function()
        if vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
        else
            feedkeys("<S-Tab>")
        end
    end, { buffer = bufnr, desc = "" })
end

local function on_attach(args)
    local bufnr = args.buf
    local buf = vim.lsp.buf

    require("telescope")
    vk.set("n", "<leader>lD", buf.declaration, { buffer = bufnr, desc = "Declaration" })
    vk.set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { buffer = bufnr, desc = "Definition" })
    vk.set("n", "<leader>li", buf.implementation, { buffer = bufnr, desc = "Implementation" })
    vk.set("n", "<leader>lt", buf.type_definition, { buffer = bufnr, desc = "Type definition" })
    vk.set("n", "<leader>lr", buf.rename, { buffer = bufnr, desc = "Rename" })
    vk.set("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>", { buffer = bufnr, desc = "References" })
    vk.set("n", "<leader>lh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = nil }))
    end, { buffer = bufnr, desc = "Toggle inlay hints" })
    vk.set("n", "<leader>lwa", buf.add_workspace_folder, { buffer = bufnr, desc = "Workspace Add Folder" })
    vk.set("n", "<leader>lwr", buf.remove_workspace_folder, { buffer = bufnr, desc = "Workspace Remove Folder" })
    vk.set("n", "<leader>lwl", function()
        print(vim.inspect(buf.list_workspace_folders()))
    end, { buffer = bufnr, desc = "Workspace List Folders" })
    -- vk.set("n", "K", function()
    --     buf.hover({ border = "rounded" })
    -- end, { buffer = bufnr })
    -- vk.set("i", "<C-s>", function()
    --     buf.signature_help({ border = "rounded" })
    -- end, { buffer = bufnr })

    -- vim.opt_local.omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.o.omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
end

local lsp = {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspStart" },
}

lsp.config = function()
    local lspconfig = require("lspconfig")
    lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
        autostart = false,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
            on_attach(args)
            lsp_completion(args)
        end,
    })

    lspconfig.clangd.setup({})
    lspconfig.rust_analyzer.setup({
        settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
    })
    lspconfig.zls.setup({})
    lspconfig.lua_ls.setup({
        settings = {
            Lua = {
                hint = {
                    enable = true,
                },
                runtime = { version = "LuaJIT" },
                workspace = {
                    library = { vim.env.VIMRUNTIME },
                    checkThirdParty = false,
                },
                format = { enable = false },
                telemetry = { enable = false },
                diagnostics = {
                    unusedLocalExclude = { "_*" },
                },
            },
        },
    })
    -- lspconfig.nil_ls.setup({})
    -- lspconfig.arduino_language_server.setup({})
end

return {
    lsp,
    {
        "mfussenegger/nvim-lint",
        ft = { "lua", "sh" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                lua = { "selene" },
                sh = { "shellcheck" },
                -- nix = { "statix" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
                group = vim.api.nvim_create_augroup("Linting", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        ft = { "lua", "sh", "markdown", "yaml", "json" },
        config = function()
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    sh = { "shfmt", "shellharden" },
                    -- nix = { "alejandra" },
                    markdown = { "prettier" },
                    yaml = { "prettier" },
                    json = { "jq" },
                },
            })
            conform.formatters.shfmt = { prepend_args = { "-i", "4" } }
            vk.set("n", "<leader>bf", function()
                conform.format({ async = true, lsp_fallback = true })
            end, { remap = true, desc = "Format buffer" })
        end,
    },
}
