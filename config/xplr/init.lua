version = "0.20.2"

-- local home = os.getenv("HOME")
-- package.path = home
-- .. "/.config/xplr/plugins/?/init.lua;"
-- .. home
-- .. "/.config/xplr/plugins/?.lua;"
-- .. package.path

xplr.config.modes.builtin.default.key_bindings.on_key.y = {
  help = "copy path",
  messages = {
    {
      BashExecSilently0 = [===[
        if [[ $(loginctl show-session self -p Type | awk -F "=" '/Type/ {print $NF}') == "wayland" ]]; then
            readlink -fn "$XPLR_FOCUS_PATH" | wl-copy
        else
            readlink -fn "$XPLR_FOCUS_PATH" | xclip -selection clipboard
        fi
      ]===],
    },
  },
}

xplr.config.modes.builtin.default.key_bindings.on_key.P = {
  help = "preview img",
  messages = {
    {
      BashExecSilently0 = [===[
        FIFO_PATH="/tmp/xplr.fifo"

        if [ -e "$FIFO_PATH" ]; then
          "$XPLR" -m StopFifo
          rm -f -- "$FIFO_PATH"
        else
          mkfifo "$FIFO_PATH"
          "$HOME/.config/xplr/img-preview.bash" "$FIFO_PATH" "$XPLR_FOCUS_PATH" &
          "$XPLR" -m 'StartFifo: %q' "$FIFO_PATH"
        fi
      ]===],
    },
  },
}

xplr.config.modes.builtin.default.key_bindings.on_key.o = {
  help = "open through mimetype",
  messages = {
    {
      LuaEvalSilently = [[function (app)
        path = app.focused_node.absolute_path
        os.execute(string.format('handlr open "%s"', path))
      end]]
    },
  },
}
