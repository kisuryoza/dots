local vk = vim.keymap

local function lsp_completion(args)
    vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
    -- vim.o.omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local methods = vim.lsp.protocol.Methods
    if not client:supports_method(methods.textDocument_completion, nil) then return end

    vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = false,
    })

    local function feedkeys(key) vim.api.nvim_feedkeys(vim.keycode(key), "n", true) end

    local function pumvisible() return tonumber(vim.fn.pumvisible()) ~= 0 end

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

    -- vk.set("n", "grn", vim.lsp.buf.rename, { buffer = args.buf })
    -- vk.set("n", "gra", vim.lsp.buf.code_action, { buffer = args.buf })
    -- vk.set("n", "grr", vim.lsp.buf.references, { buffer = args.buf })
    -- vk.set("n", "gri", vim.lsp.buf.implementation, { buffer = args.buf })
    -- vk.set("n", "gO", vim.lsp.buf.document_symbol, { buffer = args.buf })
    -- vk.set("i", "<c-s>", vim.lsp.buf.signature_help, { buffer = args.buf })

    require("telescope")
    vk.set("n", "<leader>lD", buf.declaration, { buffer = bufnr, desc = "Declaration" })
    vk.set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { buffer = bufnr, desc = "Definition" })
    -- vk.set("n", "<leader>li", buf.implementation, { buffer = bufnr, desc = "Implementation" })
    vk.set("n", "<leader>lt", buf.type_definition, { buffer = bufnr, desc = "Type definition" })
    -- vk.set("n", "<leader>lr", buf.rename, { buffer = bufnr, desc = "Rename" })
    vk.set("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>", { buffer = bufnr, desc = "References" })
    vk.set(
        "n",
        "<leader>lh",
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = nil })) end,
        { buffer = bufnr, desc = "Toggle inlay hints" }
    )
    vk.set("n", "<leader>lwa", buf.add_workspace_folder, { buffer = bufnr, desc = "Workspace Add Folder" })
    vk.set("n", "<leader>lwr", buf.remove_workspace_folder, { buffer = bufnr, desc = "Workspace Remove Folder" })
    vk.set(
        "n",
        "<leader>lwl",
        function() print(vim.inspect(buf.list_workspace_folders())) end,
        { buffer = bufnr, desc = "Workspace List Folders" }
    )
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(args)
        on_attach(args)
        lsp_completion(args)
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

vim.lsp.config("rust-analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = {
        "Cargo.toml",
        ".git",
    },
    settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})
vim.lsp.enable("rust-analyzer")

vim.lsp.config("luals", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
    },
    settings = {
        Lua = {
            hint = { enable = true },
            runtime = { version = "LuaJIT" },
            workspace = {
                library = { vim.env.VIMRUNTIME },
                checkThirdParty = false,
            },
            format = { enable = false },
            diagnostics = {
                unusedLocalExclude = { "_*" },
            },
        },
    },
})
vim.lsp.enable("luals")
