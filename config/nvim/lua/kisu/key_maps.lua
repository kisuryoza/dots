local vk = vim.keymap

vk.set("t", "<Esc>", vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), { desc = "Exit terminal mode" })

vk.set("n", "<C-d>", "<C-d>zz")
vk.set("n", "<C-u>", "<C-u>zz")
vk.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "Turn off highlighting" })
vk.set("n", "<C-t>", "<cmd>tabnew<CR>")

vk.set("v", "y", "ygv<esc>", { desc = "Yank sel text w/out moving cursor back" })
vk.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected Down" })
vk.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected Up" })

vk.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "ZenMode" })

---
---@param option string
---@param on any
---@param off any
local function toggle_opt(option, on, off)
    local curr_value = (vim.opt[option]):get()
    if type(curr_value) == "table" then
        curr_value = curr_value[next(curr_value)]
    end
    if curr_value == on then
        vim.opt[option] = off
    else
        vim.opt[option] = on
    end
end

-- stylua: ignore start
vk.set("n", "<leader>on", function() toggle_opt("number", true, false) end, { desc = "Number" })
vk.set("n", "<leader>or", function() toggle_opt("relativenumber", true, false) end, { desc = "Relative number" })
vk.set("n", "<leader>ov", function() toggle_opt("virtualedit", "all", "block") end, { desc = "Virtual edit" })
vk.set("n", "<leader>oi", function() toggle_opt("list", true, false) end, { desc = "Show invisible" })
vk.set("n", "<leader>os", function() toggle_opt("spell", true, false) end, { desc = "Spell" })
vk.set("n", "<leader>ow", function() toggle_opt("wrap", true, false) end, { desc = "Wrap" })
vk.set("n", "<leader>oc", function() toggle_opt("colorcolumn", "80", "0") end, { desc = "Color column" })
vk.set("n", "<leader>ol", function() toggle_opt("cursorline", true, false) end, { desc = "Cursor line" })
-- stylua: ignore end

vk.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic menu" })
vk.set("n", "<leader>bq", vim.diagnostic.setqflist, { desc = "Add all diags to qflist" })
vk.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "qflist prev" })
vk.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "qflist next" })
vk.set("n", "<leader>bl", vim.diagnostic.setloclist, { desc = "Add buf diags to loclist" })
vk.set("n", "[l", "<cmd>lprev<CR>zz", { desc = "loclist prev" })
vk.set("n", "]l", "<cmd>lnext<CR>zz", { desc = "loclist next" })

vk.set("n", "<leader>bd", "<cmd>lcd %:p:h<CR>", { desc = "Set local working dir" })
vk.set("n", "<leader>bD", "<cmd>cd %:p:h<CR>", { desc = "Set global working dir" })

vk.set("n", "<leader>fc", "<cmd>e $MYVIMRC | :cd %:p:h<CR>", { desc = "Edit neovm config" })
vk.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { desc = "Make curr file executable" })

vk.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vk.set("n", "<leader>cf", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
