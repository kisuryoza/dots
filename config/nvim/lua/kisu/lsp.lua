local map = vim.keymap.set

local function on_attach(args)
    local bufnr = args.buf
    local buf = vim.lsp.buf

    -- map("n", "grn", vim.lsp.buf.rename, { buffer = args.buf })
    -- map("n", "gra", vim.lsp.buf.code_action, { buffer = args.buf })
    -- map("n", "grr", vim.lsp.buf.references, { buffer = args.buf })
    -- map("n", "gri", vim.lsp.buf.implementation, { buffer = args.buf })
    -- map("n", "gO", vim.lsp.buf.document_symbol, { buffer = args.buf })
    -- map("i", "<c-s>", vim.lsp.buf.signature_help, { buffer = args.buf })

    map("n", "<leader>lD", buf.declaration, { buffer = bufnr, desc = "Declaration" })
    map("n", "<leader>ld", buf.definition, { buffer = bufnr, desc = "Definition" })
    -- map("n", "<leader>li", buf.implementation, { buffer = bufnr, desc = "Implementation" })
    map("n", "<leader>lt", buf.type_definition, { buffer = bufnr, desc = "Type definition" })
    -- map("n", "<leader>lr", buf.rename, { buffer = bufnr, desc = "Rename" })
    -- map("n", "<leader>lR", buf.references, { buffer = bufnr, desc = "References" })
    map(
        "n",
        "<leader>lh",
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = nil })) end,
        { buffer = bufnr, desc = "Toggle inlay hints" }
    )
    map("n", "<leader>lwa", buf.add_workspace_folder, { buffer = bufnr, desc = "Workspace Add Folder" })
    map("n", "<leader>lwr", buf.remove_workspace_folder, { buffer = bufnr, desc = "Workspace Remove Folder" })
    map(
        "n",
        "<leader>lwl",
        function() print(vim.inspect(buf.list_workspace_folders())) end,
        { buffer = bufnr, desc = "Workspace List Folders" }
    )
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method("textDocument/completion") then
            -- vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
            -- vim.o.omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
            vim.lsp.completion.enable(true, client.id, ev.buf, {
                autotrigger = false,
            })

            -- snippets
            local function feedkeys(key) vim.api.nvim_feedkeys(vim.keycode(key), "n", true) end
            local function pumvisible() return tonumber(vim.fn.pumvisible()) ~= 0 end

            map("i", "<Tab>", function()
                if pumvisible() then
                    feedkeys("<C-y>")
                elseif vim.snippet.active({ direction = 1 }) then
                    vim.snippet.jump(1)
                else
                    feedkeys("<Tab>")
                end
            end, { buffer = ev.buf, desc = "" })

            map("i", "<S-Tab>", function()
                if vim.snippet.active({ direction = -1 }) then
                    vim.snippet.jump(-1)
                else
                    feedkeys("<S-Tab>")
                end
            end, { buffer = ev.buf, desc = "" })
        end

        on_attach(ev)
    end,
})

vim.lsp.config("zls", {
    cmd = { "zls" },
    filetypes = { "zig", "zir" },
    root_markers = {
        "build.zig",
        ".git",
    },
})
vim.lsp.enable("zls")

vim.lsp.config("clangd", {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        ".git",
    },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { "utf-8", "utf-16" },
    },
})
-- vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = {
        "Cargo.toml",
        ".git",
    },
    settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("luals", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { "stylua.toml" },
    settings = {
        Lua = {
            hint = { enable = true },
            runtime = { version = "LuaJIT" },
            workspace = {
                library = { vim.env.VIMRUNTIME },
                checkThirdParty = false,
            },
            diagnostics = {
                unusedLocalExclude = { "_*" },
            },
        },
    },
})
vim.lsp.enable("luals")
