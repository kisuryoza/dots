(import-macros {: pack} :macros)

[(require :plugins.ide.lspconfig)
 (require :plugins.ide.dap)
 ;; install and manage LSP servers, DAP servers, linters, and formatters
 ;; (pack :williamboman/mason.nvim {:dependencies [(pack :williamboman/mason-lspconfig.nvim {:config true})]
 ;;                                 :config true})
 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 ;; (pack :jose-elias-alvarez/null-ls.nvim
 ;;       {:config #(let [null-ls (require :null-ls)
 ;;                         sources
 ;;                          [;; nix
 ;;                           null-ls.builtins.diagnostics.statix
 ;;                           null-ls.builtins.code_actions.statix]]
 ;;                           ;; null-ls.builtins.formatting.alejandra]]
 ;;                   (null-ls.setup {: sources}))})
 (pack :mfussenegger/nvim-lint
       {:config (fn []
                  (let [lint (require :lint)]
                    (set lint.linters_by_ft {:sh [:shellcheck] :nix [:statix]}))
                  (vim.api.nvim_create_autocmd :InsertLeave
                                               {:pattern [:*sh :*nix]
                                                :callback (fn []
                                                            ((. (require :lint)
                                                                :try_lint)))}))})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen {:dependencies [:nvim-treesitter/nvim-treesitter]
                        :cmd :Neogen
                        :opts {:snippet_engine :luasnip}})]

