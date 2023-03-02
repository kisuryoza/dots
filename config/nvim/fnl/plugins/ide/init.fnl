(import-macros {: pack : setup!} :macros)

[(require :plugins.ide.lspconfig)
 (require :plugins.ide.dap)
 ;; install and manage LSP servers, DAP servers, linters, and formatters
 ;; (pack :williamboman/mason.nvim {:dependencies [(pack :williamboman/mason-lspconfig.nvim {:config #((setup! :mason-lspconfig))})]
 ;;                                 :config #((setup! :mason))})
 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 (pack :jose-elias-alvarez/null-ls.nvim {:config (fn []
                                                   (local null-ls (require :null-ls))
                                                   (local sources [null-ls.builtins.formatting.fnlfmt
                                                                   (null-ls.builtins.formatting.shfmt.with {:extra_args ["-i" "4"]})
                                                                   null-ls.builtins.code_actions.statix
                                                                   null-ls.builtins.formatting.alejandra])
                                                   (null-ls.setup {: sources}))})
 (pack :folke/trouble.nvim {:config #((setup! :trouble))})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen {:dependencies [:nvim-treesitter/nvim-treesitter]
                        :config #((setup! :neogen))
                        :cmd :Neogen})]

