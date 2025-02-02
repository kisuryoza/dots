local M = {}

local align = "%="
local reset = "%*"

--[[ local LSP_progress = ""
vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    local name = vim.lsp.get_client_by_id(ctx.client_id).name
    local val = result.value

    if not val.kind then
        return
    end

    if val.kind == "begin" then
        LSP_progress = "%#DiagnosticFloatingError#" .. name
    elseif val.kind == "report" then
        LSP_progress = "%#DiagnosticFloatingWarn#" .. name
    elseif val.kind == "end" then
        LSP_progress = "%#DiagnosticFloatingInfo#" .. name
    end
end ]]

---@class Statusline
---@field arr table
local Statusline = {}

---@return Statusline
function Statusline:new()
    local init = {}
    init.arr = {}
    self.__index = self
    return setmetatable(init, self)
end

---@param str string|false
---@param postfix string?
function Statusline:insert(str, postfix)
    if str then
        table.insert(self.arr, str .. (postfix or ""))
    end
end

---@return string
function Statusline:get()
    return table.concat(self.arr)
end

---@return boolean
local function is_active()
    local winid = vim.api.nvim_get_current_win()
    local curwin = tonumber(vim.g.actual_curwin)
    return winid == curwin
end

local function get_hl(name)
    return vim.api.nvim_get_hl(0, { name = name })
end

local modes = {
    default = { " ", get_hl("NonText").fg },
    n = { "N", get_hl("diffAdded").fg },
    v = { "V", get_hl("diffChanged").fg },
    V = { "VL", get_hl("diffChanged").fg },
    ["\22"] = { "VB", get_hl("diffChanged").fg },
    i = { "I", get_hl("diffRemoved").fg },
    R = { "R", get_hl("diffRemoved").fg },
    Rv = { "VR", get_hl("diffRemoved").fg },
    c = { "C", get_hl("diffRemoved").fg },
    nt = { "NT", get_hl("diffAdded").fg },
    t = { "T", get_hl("diffRemoved").fg },
}

---@return string
local function mode()
    local curr_mode = vim.fn.mode(1)
    curr_mode = modes[curr_mode] or modes.default
    local label, color = curr_mode[1], curr_mode[2]
    vim.api.nvim_set_hl(0, "kisu_stl_mode", { fg = "black", bg = color, bold = true })
    return "%#kisu_stl_mode# " .. label
end

---@return string|false
local function git()
    local status = vim.b.gitsigns_status_dict
    if not status then
        return false
    end

    local label = {}

    table.insert(label, "%#kisu_stl_gitbranch#")
    table.insert(label, "󰘬 " .. status.head)

    local added, changed, removed = status.added, status.changed, status.removed
    if added and added > 0 then
        table.insert(label, "%#kisu_stl_diffAdded#" .. "+" .. added)
    end
    if changed and changed > 0 then
        table.insert(label, "%#kisu_stl_diffChanged#" .. "~" .. changed)
    end
    if removed and removed > 0 then
        table.insert(label, "%#kisu_stl_diffRemoved#" .. "-" .. removed)
    end

    return table.concat(label, " ")
end

---@param n number
---@param threshold number
---@return boolean
local function fits_within_window_width(n, threshold)
    local width = vim.api.nvim_win_get_width(0)
    return n / width <= threshold
end

---@return string
local function file()
    local label = {}

    table.insert(label, "%#kisu_stl_file#")

    local filename = vim.api.nvim_buf_get_name(0)
    local path = vim.fn.fnamemodify(filename, ":.")
    if path == "" then
        table.insert(label, "[No Name]")
        return table.concat(label, " ")
    end

    if not fits_within_window_width(#path, 0.3) then
        path = vim.fn.pathshorten(path, 5)
    end
    if not fits_within_window_width(#path, 0.3) then
        path = vim.fn.pathshorten(path, 3)
    end
    if not fits_within_window_width(#path, 0.3) then
        path = vim.fn.pathshorten(path, 1)
    end
    table.insert(label, path)

    if vim.bo.modified then
        table.insert(label, "●")
    end
    if vim.bo.readonly then
        table.insert(label, "%#ErrorMsg# ")
    end
    if vim.bo.buftype == "terminal" then
        table.insert(label, "")
    end

    return table.concat(label, " ")
end

---@return string|false
local function lsp()
    local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warns = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local infos = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    local hints = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    if #errors == 0 and #warns == 0 and #infos == 0 and #hints == 0 then
        return false
    end

    local label = {}

    if #errors ~= 0 then
        table.insert(label, "%#kisu_stl_diagError#󰝥 " .. #errors)
    end
    if #warns ~= 0 then
        table.insert(label, "%#kisu_stl_diagWarn#󰝥 " .. #warns)
    end
    if #infos ~= 0 then
        table.insert(label, "%#kisu_stl_diagInfo#󰝥 " .. #infos)
    end
    if #hints ~= 0 then
        table.insert(label, "%#kisu_stl_diagHint#󰌵 " .. #hints)
    end

    return table.concat(label, " ")
end

---@return string|false
local function file_encoding()
    local label = vim.bo.fileencoding
    return (label ~= "utf-8") and "%#WarningMsg# " .. label:upper()
end

---@return string|false
local function file_format()
    local label = vim.bo.fileformat
    return (label ~= "unix") and "%#WarningMsg# " .. label:upper()
end

---@return string
local function ruler()
    return "%#kisu_stl_ruler# %l/%L:%c %P " .. reset
end

---@return string
local function file_type()
    return "%#kisu_stl_filetype# " .. vim.bo.filetype:upper()
end

---@return string
local function active()
    local stl = Statusline:new()

    -- " %#kisu_stl_sep#┃"
    stl:insert(mode(), " " .. reset)
    stl:insert(file(), " " .. reset)
    stl:insert("%#kisu_stl_bg#")
    stl:insert(git())
    stl:insert(align)
    -- stl:insert(LSP_progress, " " .. reset)
    stl:insert(lsp(), " " .. reset)
    stl:insert(file_encoding(), " " .. reset)
    stl:insert(file_format(), " " .. reset)
    stl:insert(ruler())
    stl:insert(file_type(), " ")

    return stl:get()
end

---@return string
local function inactive()
    local stl = Statusline:new()

    stl:insert(file())
    stl:insert(git())
    stl:insert(align)
    stl:insert(lsp())
    stl:insert(ruler())
    stl:insert(file_type(), " ")

    return stl:get()
end

---@return string
local function dap()
    return file()
end

---@return string
function M.eval_statusline()
    local filetypes = {
        ["^dap.*"] = dap,
        ["^git.*"] = function()
            return ""
        end,
        alpha = function()
            return ""
        end,
    }

    local str = vim.bo.filetype
    local statusline
    for k, v in pairs(filetypes) do
        if str:find(k) then
            statusline = v()
        end
    end

    if is_active() then
        if not statusline then
            statusline = active()
        end
        return statusline
    else
        if not statusline then
            statusline = inactive()
        end
        local ret = statusline:gsub("%%#[^#]*#", "")
        return ret
    end
end

function M.setup()
    vim.api.nvim_set_hl(0, "kisu_stl_sep", { fg = get_hl("WinSeparator").fg })
    vim.api.nvim_set_hl(0, "kisu_stl_file", { fg = "black", bg = get_hl("Title").fg })
    vim.api.nvim_set_hl(0, "kisu_stl_ruler", { fg = "black", bg = get_hl("Identifier").fg })
    vim.api.nvim_set_hl(0, "kisu_stl_filetype", { fg = "black", bg = get_hl("Statement").fg, bold = true })
    local bg = get_hl("CursorColumn").bg
    vim.api.nvim_set_hl(0, "kisu_stl_bg", { bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_gitbranch", { fg = get_hl("Boolean").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diffAdded", { fg = get_hl("diffAdded").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diffChanged", { fg = get_hl("diffChanged").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diffRemoved", { fg = get_hl("diffRemoved").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diagError", { fg = get_hl("DiagnosticFloatingError").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diagWarn", { fg = get_hl("DiagnosticFloatingWarn").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diagInfo", { fg = get_hl("DiagnosticFloatingInfo").fg, bg = bg })
    vim.api.nvim_set_hl(0, "kisu_stl_diagHint", { fg = get_hl("DiagnosticFloatingHint").fg, bg = bg })
    vim.o.statusline = "%{%v:lua.require'kisu.statusline'.eval_statusline()%}"
end

return M
