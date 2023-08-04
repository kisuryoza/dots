(import-macros {: pack : setup!} :macros)

[(require :plugins.ide.lspconfig)
 (require :plugins.ide.dap)
 ;; install and manage LSP servers, DAP servers, linters, and formatters
 ;; (pack :williamboman/mason.nvim {:dependencies [(pack :williamboman/mason-lspconfig.nvim {:config true})]
 ;;                                 :config true})
 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 (pack :jose-elias-alvarez/null-ls.nvim
       {:config (fn []
                  (local null-ls (require :null-ls))
                  (local sources
                         [;; fennel
                          null-ls.builtins.formatting.fnlfmt
                          ;; json
                          null-ls.builtins.formatting.jq
                          ;; shell
                          (null-ls.builtins.formatting.shfmt.with {:extra_args [:-i :4]})
                          ;; nix
                          null-ls.builtins.diagnostics.statix
                          null-ls.builtins.code_actions.statix
                          null-ls.builtins.formatting.alejandra])
                  (null-ls.setup {: sources}))
        :ft [:fennel :sh :nix :json]})
 ;; (pack :mfussenegger/nvim-lint
 ;;       {:config (fn []
 ;;                  (local lint (require :lint))
 ;;                  (set lint.linters_by_ft {:sh [:shellcheck] :nix [:statix]})
 ;;                  (vim.api.nvim_create_autocmd [:InsertLeave]
 ;;                                               {:pattern [:sh :nix]
 ;;                                                :callback (fn []
 ;;                                                            ((. (require :lint)
 ;;                                                                :try_lint)))}))})
 (pack :folke/trouble.nvim {:config true})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen {:dependencies [:nvim-treesitter/nvim-treesitter]
                        :opts {:snippet_engine :luasnip}
                        :cmd :Neogen})]
