(fn get-color [group attr]
  (vim.fn.synIDattr (vim.fn.synIDtrans (vim.fn.hlID group)) attr))

(local M [])
(set M.colors {
               :bg (get-color "CursorLine" "bg#")
               :bg2 (get-color "ColorColumn" "bg#")
               :bg_dark (get-color "TabLine" "bg#")
               :fg (get-color "Normal" "fg#")

               ;; :red color-scheme.sp2
               :err (get-color "ErrorMsg" "fg#")
               :warn (get-color "WarningMsg" "fg#")})
               ;; :yellow color-scheme.op})

M
