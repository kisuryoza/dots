(import-macros {: pack
                : setup!} :macros)

[(require :plugins.ide.lspconfig)
 (require :plugins.ide.dap)

 ;; install and manage LSP servers, DAP servers, linters, and formatters
 ;; (pack :williamboman/mason.nvim {:dependencies [(pack :williamboman/mason-lspconfig.nvim {:config #((setup! :mason-lspconfig))})]
 ;;                                 :config #((setup! :mason))})

 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 (pack :folke/trouble.nvim {:config #((setup! :trouble))})

 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen {:dependencies [:nvim-treesitter/nvim-treesitter]
                        :config #((setup! :neogen))})]

;; A pretty window for previewing, navigating and editing your LSP locations in one place, inspired by vscode's peek preview.
;; (pack :DNLHC/glance.nvim {:config #(require :glance)})
