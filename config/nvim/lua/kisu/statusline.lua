local M = {}

local align = "%="
local reset = "%*"

-- ---@class Statusline
-- ---@field arr table
-- local Statusline = {}

-- ---@return Statusline
-- function Statusline:new()
--     local init = {}
--     init.arr = {}
--     self.__index = self
--     return setmetatable(init, self)
-- end

-- ---@param str string|false
-- ---@param postfix string?
-- function Statusline:insert(str, postfix)
--     if str then table.insert(self.arr, str .. (postfix or "")) end
-- end

-- ---@return string
-- function Statusline:get() return table.concat(self.arr) end

---@return boolean
local function is_active()
    local winid = vim.api.nvim_get_current_win()
    local curwin = tonumber(vim.g.actual_curwin)
    return winid == curwin
end

local function get_hl(name) return vim.api.nvim_get_hl(0, { name = name }) end

local modes = {
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
    local label, color
    if modes[curr_mode] then
        curr_mode = modes[curr_mode]
        label = curr_mode[1]
        color = curr_mode[2]
    else
        label = curr_mode
        color = get_hl("Text").fg
    end
    vim.api.nvim_set_hl(0, "sl_mode", { fg = color, bg = get_hl("TabLine").bg, bold = true })
    return "%#sl_mode# " .. label
end

---@return string
local function git()
    local status = vim.b.gitsigns_status_dict
    if not status then return "" end

    local label = {}

    table.insert(label, status.head .. " ")

    local added, changed, removed = status.added, status.changed, status.removed
    if added and added > 0 then table.insert(label, "+" .. added) end
    if changed and changed > 0 then table.insert(label, "~" .. changed) end
    if removed and removed > 0 then table.insert(label, "-" .. removed) end

    return table.concat(label)
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

    table.insert(label, "%#sl_text#")

    local filename = vim.api.nvim_buf_get_name(0)
    local path = vim.fn.fnamemodify(filename, ":.")
    if path == "" then
        table.insert(label, "[No Name]")
    else
        if not fits_within_window_width(#path, 0.3) then path = vim.fn.pathshorten(path, 5) end
        if not fits_within_window_width(#path, 0.3) then path = vim.fn.pathshorten(path, 3) end
        if not fits_within_window_width(#path, 0.3) then path = vim.fn.pathshorten(path, 1) end
        table.insert(label, path)

        if vim.bo.modified then table.insert(label, " ●") end
        if vim.bo.readonly then table.insert(label, " %#sl_diagError#") end
        if vim.bo.buftype == "terminal" then table.insert(label, "") end
    end
    return table.concat(label)
end

---@return string
local function lsp()
    local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warns = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local infos = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    local hints = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

    local label = {}

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        table.insert(label, "%#sl_text#")
        for _, client in ipairs(clients) do
            table.insert(label, client.name)
        end
    end

    if #errors ~= 0 then table.insert(label, " %#sl_diagError#󰝥 " .. #errors) end
    if #warns ~= 0 then table.insert(label, " %#sl_diagWarn#󰝥 " .. #warns) end
    if #infos ~= 0 then table.insert(label, " %#sl_diagInfo#󰝥 " .. #infos) end
    if #hints ~= 0 then table.insert(label, " %#sl_diagHint#󰌵 " .. #hints) end

    return table.concat(label)
end

---@return string|nil
local function file_encoding()
    local label = vim.bo.fileencoding
    return (label ~= "utf-8") and "%#sl_text#" .. label:upper() or nil
end

---@return string|nil
local function file_format()
    local label = vim.bo.fileformat
    return (label ~= "unix") and "%#sl_text#" .. label:upper() or nil
end

---@return string
local function ruler() return "%#sl_text#%l/%L:%c %P" end

---@return string
local function file_type() return "%#sl_text#" .. vim.bo.filetype:upper() end

---@return string
function M.eval_statusline()
    local filetypes = {
        ["^dap.*"] = file,
        ["^git.*"] = function() return "" end,
    }

    local filetype = vim.bo.filetype
    for k, v in pairs(filetypes) do
        if filetype:find(k) then return v() end
    end

    local arr = {}

    if is_active() then table.insert(arr, mode()) end
    table.insert(arr, file())
    table.insert(arr, git())
    table.insert(arr, align)
    table.insert(arr, lsp())
    local encoding = file_encoding()
    if encoding then table.insert(arr, encoding) end
    local format = file_format()
    if format then table.insert(arr, format) end
    table.insert(arr, ruler())
    table.insert(arr, file_type())
    table.insert(arr, "")
    local str = table.concat(arr, " ")

    if not is_active() then
        local ret = str:gsub("%%#[^#]*#", "")
        return ret
    end
    return str
end

function M.setup()
    local function set_hl(name, fg_hl)
        local bg = get_hl("TabLine").bg
        vim.api.nvim_set_hl(0, name, { fg = fg_hl, bg = bg })
    end
    set_hl("sl_text", get_hl("Text").fg)
    set_hl("sl_diagError", get_hl("DiagnosticFloatingError").fg)
    set_hl("sl_diagWarn", get_hl("DiagnosticFloatingWarn").fg)
    set_hl("sl_diagInfo", get_hl("DiagnosticFloatingInfo").fg)
    set_hl("sl_diagHint", get_hl("DiagnosticFloatingHint").fg)
    vim.o.statusline = "%{%v:lua.require'kisu.statusline'.eval_statusline()%}"
end

return M
