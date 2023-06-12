(import-macros {: pack : setup!} :macros)

[(require :plugins.ide.lspconfig)
 (require :plugins.ide.dap)
 ;; install and manage LSP servers, DAP servers, linters, and formatters
 ;; (pack :williamboman/mason.nvim {:dependencies [(pack :williamboman/mason-lspconfig.nvim {:config #((setup! :mason-lspconfig))})]
 ;;                                 :config #((setup! :mason))})
 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 (pack :jose-elias-alvarez/null-ls.nvim {:config (fn []
                                                   (local null-ls (require :null-ls))
                                                   (local sources [;; fennel
                                                                   null-ls.builtins.formatting.fnlfmt
                                                                   ;; shell
                                                                   null-ls.builtins.diagnostics.shellcheck
                                                                   null-ls.builtins.code_actions.shellcheck
                                                                   (null-ls.builtins.formatting.shfmt.with {:extra_args ["-i" "4"]})
                                                                   ;; nix
                                                                   null-ls.builtins.diagnostics.statix
                                                                   null-ls.builtins.code_actions.statix
                                                                   null-ls.builtins.formatting.alejandra])
                                                   (null-ls.setup {: sources}))
                                          :ft [:fennel :sh :nix]})
 (pack :folke/trouble.nvim {:config #((setup! :trouble))})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen {:dependencies [:nvim-treesitter/nvim-treesitter]
                        :config #((setup! :neogen))
                        :cmd :Neogen})]

