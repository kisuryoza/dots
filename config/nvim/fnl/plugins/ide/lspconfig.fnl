(import-macros {: pack : setup! : cmd} :macros)

;; lsp config
(local M (pack :neovim/nvim-lspconfig
               {:dependencies [;; renders diagnostics using virtual lines on top of the real line of code
                               {:url "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
                                :config (fn []
                                          ((setup! :lsp_lines))
                                          (vim.diagnostic.config {:virtual_text false}))}
                               ;; implementation of LSP inlay hint
                               (pack :lvimuser/lsp-inlayhints.nvim
                                     {:config #((setup! :lsp-inlayhints) {:inlay_hints {:type_hints {:prefix "=> "
                                                                                                     :remove_colon_start true}
                                                                                        :highlight :Comment}})})
                               ;; A pretty window for previewing, navigating and editing your LSP locations in one place
                               (pack :dnlhc/glance.nvim
                                     {:config #((setup! :glance))})
                               ;; A VS Code like winbar for Neovim
                               (pack :utilyre/barbecue.nvim
                                     {:dependencies [;; shows code context
                                                     :SmiteshP/nvim-navic]
                                      :config #((setup! :barbecue))})
                               ;; helps managing crates.io dependencies
                               (pack :saecki/crates.nvim
                                     {:config #((setup! :crates))
                                      :event "BufRead Cargo.toml"})]
                               ;; CompetiTest.nvim is a Neovim plugin to automate testcases management and checking for Competitive Programming
                               ;; (pack :xeluxee/competitest.nvim {:dependencies [:MunifTanjim/nui.nvim]
                               ;;                                  :config #((setup! :competitest))})]
                :ft [:cpp :rust :fennel :sh]}))

(fn M.config []
  (vim.fn.sign_define :DiagnosticSignError
                      {:text " " :texthl :DiagnosticSignError})
  (vim.fn.sign_define :DiagnosticSignWarn
                      {:text " " :texthl :DiagnosticSignWarn})
  (vim.fn.sign_define :DiagnosticSignInfo
                      {:text " " :texthl :DiagnosticSignInfo})
  (vim.fn.sign_define :DiagnosticSignHint
                      {:text "" :texthl :DiagnosticSignHint})
  (local lspconfig (require :lspconfig))
  (local navic (require :nvim-navic))
  (tset (require :lspconfig.configs) :fennel_language_server
        {:default_config {:cmd [(.. (vim.fn.expand "~")
                                    :/.local/bin/fennel-language-server)]
                          :filetypes [:fennel]
                          :single_file_support true
                          :root_dir (lspconfig.util.root_pattern :fnl)
                          :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                                              :diagnostics {:globals [:vim]}}}}})
  (let [on_attach (fn [client bufnr]
                    ((. (require :lsp-inlayhints) :on_attach) client bufnr)
                    (let [wk (require :which-key)]
                      (wk.register {:l {:name :+LSP
                                        :R [(cmd "Glance references")
                                            :References]
                                        :d [(cmd "Glance definitions")
                                            :Definitions]
                                        :t [(cmd "Glance type_definitions")
                                            "Type definitions"]
                                        :i [(cmd "Glance implementations")
                                            :Implementations]
                                        :r [vim.lsp.buf.rename
                                            "Renames all references to symbol"]
                                        :K [vim.lsp.buf.hover
                                            "Shows hover info about symbol in floating window"]
                                        :<C-k> [vim.lsp.buf.signature_help
                                                "Shows signature info about symbol in floating window"]
                                        :a [vim.lsp.buf.code_action
                                            "Code action"]
                                        :f [#(vim.lsp.buf.format {:async true})
                                            "Formats buffer using attached (and optionally filtered) language server clients"]}}
                                   {:prefix :<localleader>
                                    :buffer bufnr
                                    :silent true
                                    :noremap true}))
                    (when client.server_capabilities.documentSymbolProvider
                      (navic.attach client bufnr)))
        flags {:debounce_text_changes 150}
        capabilities ((. (require :cmp_nvim_lsp) :default_capabilities))]
    ;; (lspconfig.clangd.setup {:on_attach on_attach
    ;;                          :flags lsp_flags})
    (lspconfig.ccls.setup {: on_attach
                           : flags
                           : capabilities
                           :init_options {:compilationDatabaseDirectory :build
                                          :index {:threads 0}}
                           :clang {}})
    (lspconfig.rust_analyzer.setup {: on_attach
                                    : flags
                                    : capabilities
                                    :settings {:rust-analyzer {:checkOnSave {:command "clippy"}}}
                                    :cmd [:rustup :run :stable :rust-analyzer]})
    (lspconfig.bashls.setup {:filetypes [:sh]
                             : on_attach
                             : flags
                             : capabilities
                             :cmd [:node :/usr/bin/bash-language-server :start]})
    (lspconfig.fennel_language_server.setup {:filetypes [:fennel]
                                             : on_attach
                                             : flags
                                             : capabilities})))

M

