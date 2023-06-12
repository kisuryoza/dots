(import-macros {: pack : setup!} :macros)

[;; A minimal, stylish and customizable statusline / winbar / bufferline
 (require :plugins.ui.heirline)
 ;; Git integration for buffers
 (require :plugins.ui.gitsigns)
 ;; manage the file system and other tree like structures
 (require :plugins.ui.neo-tree)
 ;; completely replaces the UI for messages, cmdline and the popupmenu
 (require :plugins.ui.noice)
 ;; Telescope
 (require :plugins.ui.telescope)
 ;; popup with possible key bindings
 (require :plugins.ui.which-key)
 ;; Replaces vim.ui.select and vim.ui.input
 (pack :stevearc/dressing.nvim)
 ;; manage multiple terminal windows
 (pack :akinsho/toggleterm.nvim
       {:config #((setup! :toggleterm) {:direction :float}) :cmd :ToggleTerm})
 ;; Extensible Neovim Scrollbar
 (pack :petertriho/nvim-scrollbar
       {:config #((setup! :scrollbar) {:excluded_filetypes [:neo-tree :noice]})
        :event :BufRead})
 ;; manage undos as a tree
 (pack :jiaoshijie/undotree
       {:dependencies [:nvim-lua/plenary.nvim] :config #((setup! :undotree))})
 (pack :kevinhwang91/nvim-ufo
       {:dependencies [:kevinhwang91/promise-async]
        :config (fn []
                  (fn customize-selector [bufnr]
                    (fn handle-fallback-exception [err provider-name]
                      (if (and (= (type err) :string)
                               (err:match :UfoFallbackException))
                          ((. (require :ufo) :getFolds) bufnr provider-name)
                          ((. (require :promise) :reject) err)))

                    (: (: ((. (require :ufo) :getFolds) bufnr :lsp) :catch
                          (fn [err] (handle-fallback-exception err :treesitter)))
                       :catch (fn [err] (handle-fallback-exception err :indent))))

                  ((setup! :ufo) {:provider_selector (fn [bufnr
                                                          filetype
                                                          buftype]
                                                       customize-selector)})
                  (set vim.o.foldmethod :expr)
                  (set vim.o.fillchars
                       "eob: ,fold: ,foldopen:,foldsep: ,foldclose:")
                  (set vim.o.foldcolumn :1)
                  (set vim.o.foldlevel 99)
                  (set vim.o.foldlevelstart 99)
                  (set vim.o.foldenable true))})]
