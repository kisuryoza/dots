(import-macros {: pack} :macros)

[(require :plugins.ide.lspconfig)
 (require :plugins.ide.dap)
 ;; helps managing crates.io dependencies
 (pack :saecki/crates.nvim {:event "BufRead Cargo.toml" :config true})
 ;; Treesitter based structural search and replace
 ; (pack :cshuaimin/ssr.nvim {:lazy true})
 ;; install and manage LSP servers, DAP servers, linters, and formatters
 ; (pack :williamboman/mason.nvim {:dependencies [(pack :williamboman/mason-lspconfig.nvim {:config true})]
 ;                                 :config true})
 ;; A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
 ; (pack :jose-elias-alvarez/null-ls.nvim
 ;       {:config #(let [null-ls (require :null-ls)
 ;                         sources
 ;                          [;; nix
 ;                           null-ls.builtins.diagnostics.statix
 ;                           null-ls.builtins.code_actions.statix]]
 ;                           ;; null-ls.builtins.formatting.alejandra]]
 ;                   (null-ls.setup {: sources}))})
 ;; The Refactoring library based off the Refactoring book by Martin Fowler 
 ; (pack :ThePrimeagen/refactoring.nvim
 ;       {:opts {:prompt_func_return_type {:go true :c true :cpp true}
 ;               :prompt_func_param_type {:go true :c true :cpp true}}})
 (pack :mfussenegger/nvim-lint
       {:config (fn []
                  (let [lint (require :lint)]
                    (set lint.linters_by_ft {:nix [:statix]}))
                  (vim.api.nvim_create_autocmd :InsertLeave
                                               {:pattern [:*nix]
                                                :callback (fn []
                                                            ((. (require :lint)
                                                                :try_lint)))}))})
 ;; A better annotation generator. Supports multiple languages and annotation conventions.
 (pack :danymat/neogen {:cmd :Neogen :opts {:snippet_engine :luasnip}})]

