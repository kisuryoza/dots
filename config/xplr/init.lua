version = "0.21.0"

-- local home = os.getenv("HOME")
-- package.path = home
-- .. "/.config/xplr/plugins/?/init.lua;"
-- .. home
-- .. "/.config/xplr/plugins/?.lua;"
-- .. package.path

xplr.config.modes.builtin.default.key_bindings.on_key["y"] = {
  help = "Copy path",
  messages = {
    {
      BashExecSilently0 = [===[
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
            readlink -fn "$XPLR_FOCUS_PATH" | wl-copy
        else
            readlink -fn "$XPLR_FOCUS_PATH" | xclip -selection clipboard
        fi
      ]===],
    },
  },
}

xplr.config.modes.builtin.default.key_bindings.on_key["P"] = {
  help = "Preview img",
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

xplr.config.modes.builtin.default.key_bindings.on_key["o"] = {
  help = "Open through mimetype",
  messages = {
    {
      LuaEvalSilently = [[function (app)
        path = app.focused_node.absolute_path
        os.execute(string.format('fork.bash handlr open "%s"', path))
      end]]
    },
  },
}

xplr.config.modes.builtin.default.key_bindings.on_key["b"] = {
  help = "bookmark mode",
  messages = {
    { SwitchModeCustom = "bookmark" },
  },
}
xplr.config.modes.custom.bookmark = {
  name = "bookmark",
  key_bindings = {
    on_key = {
      a = {
        help = "Add bookmark",
        messages = {
          {
            BashExecSilently0 = [[
              BOOKMARKS="$HOME/.config/xplr/bookmarks.txt"
              PTH="${XPLR_FOCUS_PATH:?}"
              echo "$PTH" >> "$BOOKMARKS"
              sort -uo "$BOOKMARKS" "$BOOKMARKS"
            ]],
          },
          "PopMode",
        },
      },
      s = {
        help = "Select bookmark",
        messages = {
          {
            BashExec0 = [===[
              BOOKMARKS="$HOME/.config/xplr/bookmarks.txt"
              PTH=$(cat "$BOOKMARKS" | fzf --no-sort)
              if [ "$PTH" ]; then
                "$XPLR" -m 'FocusPath: %q' "$PTH"
              fi
            ]===],
          },
          "PopMode",
        },
      },
      d = {
        help = "Delete bookmark",
        messages = {
          {
            BashExec0 = [[
              BOOKMARKS="$HOME/.config/xplr/bookmarks.txt"
              PTH=$(cat "$BOOKMARKS" | fzf --no-sort)
              sd "$PTH\n" "" "$BOOKMARKS"
            ]],
          },
          "PopMode",
        },
      },
      esc = {
        help = "cancel",
        messages = {
          "PopMode",
        },
      },
    },
  },
}

