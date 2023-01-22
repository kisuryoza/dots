(import-macros {: pack} :macros)

(local M
  (pack :feline-nvim/feline.nvim))

(fn M.config []
  (fn get-color [group attr]
    (vim.fn.synIDattr (vim.fn.synIDtrans (vim.fn.hlID group)) attr))
  (local colors {:bg (get-color "CursorLine" "bg#")
                 :bg2 (get-color "ColorColumn" "bg#")
                 :bg_dark (get-color "TabLine" "bg#")
                 :fg (get-color "Normal" "fg#")

                 :err (get-color "ErrorMsg" "fg#")
                 :warn (get-color "WarningMsg" "fg#")})

  (local feline (require :feline))

  ; https://neovim.io/doc/user/builtin.html#mode()
  (local modes {:n "NORMAL"
                :no "OP-PENDING"
                :v "VISUAL"
                :V "V-LINE"
                "" "V-BLOCK"
                :i "INSERT"
                :R "REPLACE"
                :Rv "VIRT REPLACE"
                :c "COMMAND"
                :cv "EX"
                :r "HIT-ENTER"
                :r? "CONFIRM"
                :t "TERM"})

  (fn split [string separator]
    (var output [])
    (each [str (string.gmatch string separator)]
      (table.insert output str))
    output)

  (fn vim-mode []
    (let [mode (vim.fn.mode)]
      (.. " " (or (. modes mode) mode) " ")))

  (fn git []
    (let [branch (?. vim.b :gitsigns_status_dict :head)
          added (?. vim.b :gitsigns_status_dict :added)
          changed (?. vim.b :gitsigns_status_dict :changed)
          removed (?. vim.b :gitsigns_status_dict :removed)]
      (if (not= branch nil)
        (.. " 󰘬  " branch " " (if (and (not= added nil) (not= added 0))
                                (.. "+" added " ")
                                "")
                              (if (and (not= changed nil) (not= changed 0))
                                (.. "~" changed " ")
                                "")
                              (if (and (not= removed nil) (not= removed 0))
                                (.. "-" removed " ")
                                ""))
        "")))

  (fn file-name []
    (let [path (vim.api.nvim_buf_get_name 0)]
      (if (or (= path nil) (= path ""))
        ""
        (let [shorten-path (vim.fn.pathshorten path 5)
              labels (split shorten-path "%p%w+")]
          (var label "")
          ; Iterates through labels and outputs last n strings
          (for [i 3 1 -1]
            (if (< i (length labels))
              (set label (.. label (. labels (- (length labels) i))))))
          (.. label (. labels (length labels)))))))

  (fn file-name-label []
    (let [path (file-name)]
      (if (or (= path nil) (= path ""))
        ""
        vim.bo.readonly
        (.. " 󰌾 " path " ")
        vim.bo.modified
        (.. " " path " ● ")
        (.. " " path " "))))

  (fn file-type []
    (let [label vim.bo.filetype]
      (.. " " label " ")))

  (fn file-encoding []
    (let [label vim.bo.fileencoding]
      (.. " " label " ")))

  (fn file-format []
    (let [label vim.bo.fileformat]
      ;; (if (= label "unix")
        (.. " " label " ")))

  (fn cursor-pos []
    (let [[_line col] (vim.api.nvim_win_get_cursor 0)]
      (.. " " col " ")))

  (fn pos-percent []
    (let [[line _col] (vim.api.nvim_win_get_cursor 0)
          lines (vim.api.nvim_buf_line_count 0)]
      (if (= line 1)
        " Top "
        (= line lines)
        " Btm "
        (.. " " (math.ceil (* 100 (/ line lines))) "%% "))))

  (local components {:active {}
                     :inactive {}})

  (tset components.active 1 [{:provider vim-mode
                              :hl {:bg colors.bg
                                   :fg colors.fg}}
                             {:provider git
                              :hl {:bg colors.bg2
                                   :fg colors.fg}}
                             {:provider file-name-label
                              :hl {:bg colors.bg_dark
                                   :fg colors.fg}}
                             {:hl {:bg colors.bg_dark
                                   :fg colors.fg}}])

  (tset components.active 2 [])

  (tset components.active 3 [{:provider :diagnostic_info
                              :hl {:bg colors.bg_dark
                                   :fg colors.fg}}
                             {:provider :diagnostic_hints
                              :hl {:bg colors.bg_dark
                                   :fg colors.fg}}
                             {:provider :diagnostic_warnings
                              :hl {:bg colors.bg_dark
                                   :fg colors.warn}}
                             {:provider :diagnostic_errors
                              :hl {:bg colors.bg_dark
                                   :fg colors.err}}
                             {:provider file-encoding
                              :hl {:bg colors.bg_dark
                                   :fg colors.fg}}
                             {:provider file-format
                              :hl {:bg colors.bg_dark
                                   :fg colors.fg}}
                             {:provider cursor-pos
                              :hl {:bg colors.bg2
                                   :fg colors.fg}}
                             {:provider pos-percent
                              :hl {:bg colors.bg2
                                   :fg colors.fg}}
                             {:provider file-type
                              :hl {:bg colors.bg
                                   :fg colors.fg}}])

  (tset components.inactive 1 [{:provider git
                                :hl {:bg colors.bg2
                                     :fg colors.fg}}
                               {:provider file-name-label
                                :hl {:bg colors.bg_dark
                                     :fg colors.fg}}
                               {:hl {:bg colors.bg_dark
                                     :fg colors.fg}}])

  (tset components.inactive 2 [])

  (tset components.inactive 3 [{:provider file-type
                                :hl {:bg colors.bg2
                                     :fg colors.fg}}])

  (feline.setup {:components components}))

M
