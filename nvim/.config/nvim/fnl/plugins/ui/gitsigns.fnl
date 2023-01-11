(import-macros {: setup!
                : pack} :macros)

(local M
  (pack :lewis6991/gitsigns.nvim {:event "BufRead"}))

(fn M.config []
  ((setup! :gitsigns) {:numhl true})
  ((setup! :scrollbar.handlers.gitsigns)))

M
