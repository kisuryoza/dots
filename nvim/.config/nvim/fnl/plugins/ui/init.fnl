(import-macros {: pack
                : setup!} :macros)

[;; A snazzy bufferline for Neovim
 (require :plugins.ui.bufferline)
 ;; A minimal, stylish and customizable statusline / winbar
 (require :plugins.ui.feline)
 ;; Git integration for buffers
 (require :plugins.ui.gitsigns)
 ;; manage the file system and other tree like structures
 (require :plugins.ui.neo-tree)
 ;; popup with possible key bindings
 (require :plugins.ui.which-key)

 ;; Telescope
 (pack :nvim-telescope/telescope.nvim)
 ;; Replaces vim.ui.select and vim.ui.input
 (pack :stevearc/dressing.nvim)
 ;; manage multiple terminal windows
 (pack :akinsho/toggleterm.nvim {:config #((setup! :toggleterm) {:direction "float"})
                                 :cmd "ToggleTerm"})
 ;; Extensible Neovim Scrollbar
 (pack :petertriho/nvim-scrollbar {:config #((setup! :scrollbar) {:excluded_filetypes ["neo-tree"]})
                                   :event "BufRead"})
 ;; A fancy, configurable, notification manager for NeoVim
 (pack :rcarriga/nvim-notify {:config (fn []
                                        ((setup! :notify) {:render "simple"
                                                           :stages "static"
                                                           :timeout 7000})
                                        (set vim.notify (require :notify)))})
 ;; completely replaces the UI for messages, cmdline and the popupmenu
 (pack :folke/noice.nvim {:dependencies ["MunifTanjim/nui.nvim"
                                         "rcarriga/nvim-notify"]
                          :config #((setup! :noice))})
 ;; manage undos as a tree
 (pack :jiaoshijie/undotree {:dependencies ["nvim-lua/plenary.nvim"]
                             :config #((setup! :undotree))})]
