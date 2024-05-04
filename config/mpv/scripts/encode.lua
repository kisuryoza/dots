local mp = require("mp")
package.path = mp.command_native({ "expand-path", "~~/" })
    .. "/scripts/?.lua;"
    .. package.path
local utils = require("utils")
local Cmd = utils.Cmd

---@alias VideoCodec
---| '"av1"'
---| '"vp9"'
---| '"copy"'

---@class Options
---@field video_codec VideoCodec
---@field hardsub boolean
---@field start_pos number?

local default_options = {
    video_codec = "av1",
    hardsub = false,
    start_pos = nil,
}

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

    local end_pos = time_pos

    local path = mp.get_property("path")
    local cwd, filename, ext = utils.filename_ext()
    local tmp = "/tmp/" .. "encoding_artifact." .. ext
    local input = path
    local output = cwd
        .. "/"
        .. filename
        .. "."
        .. utils.format_timestamp(start_pos)
        .. "-"
        .. utils.format_timestamp(end_pos)
        .. ".webm"

    --[[ local track = mp.get_property_native("current-tracks/video")
    if track and track["codec-desc"] == "H.265 / HEVC (High Efficiency Video Coding)" then
        opts.video_codec = "av1"
    end ]]

    utils.info("Encoding the slice using '" .. opts.video_codec .. "' codec.")

    local cmd = Cmd:new("ffmpeg")
    cmd:add_args("-v", "warning")
    cmd:add_args("-y")
    cmd:add_args("-ss", tostring(start_pos))
    cmd:add_args("-accurate_seek")
    cmd:add_args("-i", input)
    cmd:add_args("-t", tostring(end_pos - start_pos))
    cmd:add_args("-c:v", "copy")
    cmd:add_args("-c:a", "copy")
    cmd:add_args("-c:s", "copy")
    cmd:add_args(
        "-map",
        string.format(
            "v:%s?",
            mp.get_property_number("current-tracks/video/id", 0) - 1
        )
    )
    cmd:add_args(
        "-map",
        string.format(
            "a:%s?",
            mp.get_property_number("current-tracks/audio/id", 0) - 1
        )
    )
    cmd:add_args(
        "-map",
        string.format(
            "s:%s?",
            mp.get_property_number("current-tracks/sub/id", 0) - 1
        )
    )
    cmd:add_args("-avoid_negative_ts", "make_zero")
    cmd:add_args(tmp)
    local res = cmd:run()
    if not (res and res.status == 0) then
        utils.error("Failed to encode")
        os.remove(tmp)
        return
    end

    input = tmp
    cmd = Cmd:new("ffmpeg")
    cmd:add_args("-v", "warning")
    cmd:add_args("-y")
    cmd:add_args("-i", input)
    if opts.hardsub then
        cmd:add_args("-vf", "subtitles=" .. input)
    end
    if opts.video_codec == "av1" then
        -- cmd:add_args("-c:v", "libsvtav1")
        -- cmd:add_args("-preset", "8")
        -- cmd:add_args("-crf", "40")
        cmd:add_args("-c:v", "librav1e")
        cmd:add_args("-tile-columns", "2", "-tile-rows", "2")
        cmd:add_args("-rav1e-params", "quantizer=120:speed=10:low_latency=true")
    elseif opts.video_codec == "vp9" then
        cmd:add_args("-c:v", "libvpx-vp9")
        cmd:add_args("-crf", "40")
        cmd:add_args("-b:v", "0")
        cmd:add_args("-cpu-used", "8")
        cmd:add_args("-tile-columns", "2", "-tile-rows", "2")
    elseif opts.video_codec == "copy" then
        cmd:add_args("-c:v", "copy")
    end
    cmd:add_args(output)
    res = cmd:run()

    os.remove(tmp)

    if res and res.status == 0 then
        utils.info("Finished encoding the slice")
    else
        utils.error("Failed to encode")
    end
end

mp.add_key_binding(nil, "slice-encode", function()
    local opts = default_options
    encode(opts)
end)

mp.add_key_binding(nil, "slice-encode-hardsub", function()
    local opts = default_options
    opts.hardsub = true
    encode(opts)
end)
