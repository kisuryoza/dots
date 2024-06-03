local vk = vim.keymap
local vl = vim.lsp

local function on_attach(ev)
    local buf = vl.buf
    vk.set("n", "<leader>lD", buf.declaration, { buffer = ev.buf, desc = "Declaration" })
    vk.set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { buffer = ev.buf, desc = "Definition" })
    vk.set("n", "<leader>li", buf.implementation, { buffer = ev.buf, desc = "Implementation" })
    vk.set("n", "<leader>lt", buf.type_definition, { buffer = ev.buf, desc = "Type definition" })
    vk.set("n", "<leader>lr", buf.rename, { buffer = ev.buf, desc = "Rename" })
    vk.set("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>", { buffer = ev.buf, desc = "References" })
    vk.set("n", "<leader>lh", function()
        vl.inlay_hint.enable(not vl.inlay_hint.is_enabled({ bufnr = nil }))
    end, { buffer = ev.buf, desc = "Toggle inlay hints" })
    vk.set("n", "<leader>lwa", buf.add_workspace_folder, { buffer = ev.buf, desc = "Workspace Add Folder" })
    vk.set("n", "<leader>lwr", buf.remove_workspace_folder, { buffer = ev.buf, desc = "Workspace Remove Folder" })

    vk.set("n", "<leader>lwl", function()
        print(vim.inspect(buf.list_workspace_folders()))
    end, { buffer = ev.buf, desc = "Workspace List Folders" })
    vk.set("i", "<C-s>", buf.signature_help, { buffer = ev.buf, desc = "Signature documentation" })
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

    vl.handlers["textDocument/signatureHelp"] = vl.with(vl.handlers["signature_help"], {
        border = "single",
    })

    local capabilities = vim.tbl_deep_extend(
        "force",
        vl.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
    )

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
            on_attach(args)
        end,
    })

    lspconfig.clangd.setup({ capabilities = capabilities })
    lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
    })
    lspconfig.bashls.setup({ capabilities = capabilities })
    lspconfig.lua_ls.setup({
        capabilities = capabilities,
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
    lspconfig.nil_ls.setup({ capabilities = capabilities })
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
                nix = { "statix" },
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
                    nix = { "alejandra" },
                    markdown = { "prettier" },
                    yaml = { "prettier" },
                    json = { "jq" },
                },
            })
            conform.formatters.shfmt = { prepend_args = { "-i", "4" } }
            vk.set("n", "<leader>cf", function()
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
