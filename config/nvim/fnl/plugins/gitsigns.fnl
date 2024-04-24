(require-macros :macros)

(local M (pack :lewis6991/gitsigns.nvim {:event :VeryLazy}))

(fn M.config []
  (local gitsigns (require :gitsigns))
  (var t {})
  (set t {:numhl true})

  (fn t.on_attach [bufnr]
    (nmapp! :gl gitsigns.toggle_linehl "Highlight lines" bufnr)
    (nmapp! :gb gitsigns.toggle_current_line_blame "Toggle line blame" bufnr)
    (nmapp! :ghr gitsigns.reset_hunk "Reset hunk" bufnr)
    (nmapp! :ghP gitsigns.preview_hunk_inline "Preview hunk" bufnr)
    (nmapp! :ghp gitsigns.prev_hunk "Prev hunk" bufnr)
    (nmapp! :ghn gitsigns.next_hunk "Next hunk" bufnr)
    (nmapp! :ghs gitsigns.select_hunk "Select hunk" bufnr))

  (gitsigns.setup t))

M

