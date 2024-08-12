local vk = vim.keymap

local function on_attach(args)
    local bufnr = args.buf
    local buf = vim.lsp.buf
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

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local methods = vim.lsp.protocol.Methods
    if not client.supports_method(methods.textDocument_completion) then
        return
    end

    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })
end

local lsp = {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "j-hui/fidget.nvim",
            opts = { notification = { window = { winblend = 0 } } },
        },
    },
    event = "VeryLazy",
}

lsp.config = function()
    local lspconfig = require("lspconfig")

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers["signature_help"], {
        border = "single",
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
            on_attach(args)
        end,
    })

    lspconfig.clangd.setup({})
    lspconfig.rust_analyzer.setup({
        settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
    })
    lspconfig.bashls.setup({})
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
    lspconfig.arduino_language_server.setup({})
end

return {
    lsp,
    {
        "mfussenegger/nvim-lint",
        event = "VeryLazy",
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
        event = "VeryLazy",
        config = function()
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    rust = { "rustfmt" },
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
    {
        "williamboman/mason.nvim",
        event = "VeryLazy",
        config = function()
            local packages = {
                "codelldb",
                "lua-language-server",
                "selene",
                "stylua",
                "bash-language-server",
                "shellcheck",
                "shfmt",
                "shellharden",
                "prettier",
            }

            require("mason").setup()
            local mason_registry = require("mason-registry")
            local show = vim.schedule_wrap(function(msg)
                vim.notify(msg, vim.log.levels.INFO)
            end)

            for _i, item in ipairs(packages) do
                local p = mason_registry.get_package(item)
                if not p:is_installed() then
                    p:once("install:success", function()
                        show(string.format("%s: successfully installed", p.name))
                    end)
                    p:install()
                end
            end
        end,
    },
}
