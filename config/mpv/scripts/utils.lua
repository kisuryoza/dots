local mp = require("mp")
local msg = require("mp.msg")

local M = {}
---@param str string|number
function M.info(str)
    msg.info(str)
    mp.osd_message(str, 3)
end

---@param str string|number
function M.error(str)
    msg.error(str)
    mp.osd_message(str, 3)
end

---@param timestamp number
---@return string
function M.format_timestamp(timestamp)
    local seconds = timestamp % 60
    seconds = math.floor(seconds)
    local minutes = timestamp / 60
    local hours = minutes / 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

---@return string, string, string
function M.filename_ext()
    local cwd = mp.get_property_native("working-directory")
    local filename = mp.get_property("filename")
    local name = mp.get_property("filename/no-ext")
    local ext = filename:sub(name:len() + 2)
    return cwd, name, ext
end

---@class Cmd
---@field args string[]
local Cmd = {}
M.Cmd = Cmd

---@param prog string
---@return Cmd
function Cmd:new(prog)
    local init = {}
    init.args = { prog }
    self.__index = self
    return setmetatable(init, self)
end

---@param ... string
function Cmd:add_args(...)
    for _, v in ipairs({ ... }) do
        self.args[#self.args + 1] = v
    end
    return self
end

---@return string
function Cmd:get_args()
    return table.concat(self.args, " ")
end

---@return table?
function Cmd:run()
    ---@class Res
    ---@field stdout string
    ---@field stderr string

    ---@type Res, string
    local res, err = mp.command_native({
        name = "subprocess",
        args = self.args,
        capture_stdout = true,
        capture_stderr = true,
    })

    if not res then
        msg.error("Failed to execute: " .. self:get_args())
        msg.error("Error: " .. err)
    else
        if res.stdout:len() ~= 0 then
            msg.info(res.stdout)
        end
        if res.stderr:len() ~= 0 then
            msg.error(res.stderr)
        end
    end
    return res
end

---@param item string|number
local function copy_to_clipboard(item)
    local prog
    if os.getenv("WAYLAND_DISPLAY") == nil then
        prog = "xclip -selection clipboard"
    else
        prog = "wl-copy"
    end

    local cmd = io.popen(prog, "w")
    if not cmd then
        M.error("Copy cmd failed")
        return
    end
    cmd:write(item)
    cmd:close()
    M.info("Copied: " .. item)
end

mp.add_key_binding(nil, "copy-timestamp", function()
    local time_pos, err = mp.get_property_number("time-pos")
    if not time_pos then
        M.error("Failed to get timestamp: " .. err)
        return
    end
    local time = M.format_timestamp(time_pos)
    if time then
        copy_to_clipboard(time)
    end
end)

return M
