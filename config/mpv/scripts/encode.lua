local mp = require("mp")
local msg = require("mp.msg")
package.path = mp.command_native({ "expand-path", "~~/" })
    .. "/scripts/?.lua;"
    .. package.path
local utils = require("utils")
local Cmd = utils.Cmd

---@alias VideoCodec
---| '"av1"'
---| '"vp9"'
---| '"copy"'

---| '"auto"'

---@class Options
---@field video_codec VideoCodec
---@field hardsub boolean
---@field start_pos number?

local default_options = {
    video_codec = "av1",
    hardsub = false,
    start_pos = nil,
}

---@class Ffmpeg_filter
---@field filter string
local Ffmpeg_filter = {}

---@param filter string
---@return Ffmpeg_filter
function Ffmpeg_filter:new(filter)
    local init = {}
    init.filter = filter
    self.__index = self
    return setmetatable(init, self)
end

---@param filter string
function Ffmpeg_filter:add_ffmpeg_filter(filter)
    if self.filter:len() == 0 then
        self.filter = filter
    else
        self.filter = self.filter .. "," .. filter
    end
end

--[[ ---@return VideoCodec
local function choose_codec()
    local track = mp.get_property_native("current-tracks/video")
    if not track then
        return "av1"
    end
    local codec = track["codec-desc"]
    if codec == "H.265 / HEVC (High Efficiency Video Coding)" then
        return "av1"
    elseif codec == "Alliance for Open Media AV1" or codec == "Google VP9" then
        return "copy"
    else
        return "av1"
    end
end ]]

---@param opts Options
local function encode(opts)
    local time_pos, err = mp.get_property_number("time-pos")
    if not time_pos then
        utils.error("Failed to get timestamp: " .. err)
        return
    end

    local start_pos = opts.start_pos
    if not start_pos then
        opts.start_pos = time_pos
        utils.info("Start cut position is set. Waiting for ending timestamp.")
        return
    end

    -- Entered this func 2nd time
    mp.remove_key_binding("remove-encode-timestamp")
    local end_pos = time_pos
    local input = mp.get_property("path")
    local path_noext = input:match("(.+)%..*$")
    local output = path_noext
        .. " ["
        .. utils.format_timestamp(start_pos)
        .. "-"
        .. utils.format_timestamp(end_pos)
        .. "].webm"

    --[[ if opts.video_codec == "auto" then
        opts.video_codec = choose_codec()
    end ]]
    utils.info("Encoding the slice using '" .. opts.video_codec .. "' codec.")

    local v = mp.get_property_number("current-tracks/video/id", 0) - 1
    local v_stream = string.format("0:v:%s", v)
    local a = mp.get_property_number("current-tracks/audio/id", 0) - 1
    local a_stream = string.format("0:a:%s", a)
    local s = mp.get_property_number("current-tracks/sub/id", 0) - 1
    local s_stream = string.format("0:s:%s", s)

    local f = Ffmpeg_filter:new("scale=-2:'min(720,ih)'")
    if opts.hardsub then
        local subs = "/tmp/_subtitles.ass"
        local cmd = Cmd:new("ffmpeg")
        cmd:args("-v", "warning", "-y", "-i", input)
        cmd:args("-map", s_stream)
        cmd:args(subs):run()
        f:add_ffmpeg_filter("subtitles=" .. subs)
    end

    local cmd = Cmd:new("ffmpeg")
    cmd:args("-v", "warning")
    cmd:args("-y")
    cmd:args("-ss", tostring(start_pos))
    cmd:args("-accurate_seek")
    cmd:args("-i", input)
    cmd:args("-t", tostring(end_pos - start_pos))

    ---
    -- Lazy solution to choosing between vobsub and ass hardsubbing
    --[[ cmd:args(
        "-filter_complex",
        "[" .. v_stream .. "][" .. s_stream .. "]overlay[v]"
    )
    v_stream = "[v]" ]]
    -- or
    cmd:args("-vf", f.filter)
    ---

    cmd:args("-map", v_stream)
    cmd:args("-map", a_stream .. "?")
    cmd:args("-c", "copy")
    cmd:args("-avoid_negative_ts", "make_zero")
    if opts.video_codec == "av1" then
        cmd:args("-c:v", "libsvtav1")
        cmd:args("-preset", "5")
        cmd:args("-crf", "40")
        cmd:args("-pix_fmt", "yuv420p10le")
        cmd:args(
            "-svtav1-params",
            "enable-qm=1:qm-min=0:qm-max=15:keyint=240:tune=2:film-grain=4:film-grain-denoise=1"
        )
    elseif opts.video_codec == "vp9" then
        cmd:args("-c:v", "libvpx-vp9")
        cmd:args("-crf", "40")
        cmd:args("-b:v", "0")
        cmd:args("-cpu-used", "8")
        cmd:args("-tile-columns", "2", "-tile-rows", "2")
    elseif opts.video_codec == "copy" then
        cmd:args("-c:v", "copy")
    end
    cmd:args("-c:a", "libopus", "-b:a", "32k")
    cmd:args(output)
    msg.info(cmd:get_args())

    local res = cmd:run()
    if res and res.status == 0 then
        utils.info("Finished encoding the slice")
    else
        utils.error("Failed to encode")
    end
end

mp.add_key_binding(nil, "slice-encode", function()
    mp.add_key_binding("ESC", "remove-encode-timestamp", function()
        default_options.start_pos = nil
        utils.info("Timestamp reseted")
        mp.remove_key_binding("remove-encode-timestamp")
    end)
    local opts = default_options
    encode(opts)
end)

mp.add_key_binding(nil, "slice-encode-hardsub", function()
    mp.add_key_binding("ESC", "remove-encode-timestamp", function()
        default_options.start_pos = nil
        utils.info("Timestamp reseted")
        mp.remove_key_binding("remove-encode-timestamp")
    end)
    local opts = default_options
    opts.hardsub = true
    encode(opts)
end)
