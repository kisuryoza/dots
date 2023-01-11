(import-macros {: pack
                : setup!} :macros)

;; lsp config
(local M
  (pack :neovim/nvim-lspconfig {:dependencies [;; renders diagnostics using virtual lines on top of the real line of code
                                               {:url "https://git.sr.ht/~whynothugo/lsp_lines.nvim" :config (fn []
                                                                                                              ((setup! :lsp_lines))
                                                                                                              (vim.diagnostic.config {:virtual_text false}))}
                                               ;; implementation of LSP inlay hint
                                               (pack :lvimuser/lsp-inlayhints.nvim {:config #((setup! :lsp-inlayhints) {:inlay_hints {:type_hints {:prefix "=> "
                                                                                                                                                   :remove_colon_start true}
                                                                                                                                      :highlight "Comment"}})})
                                               ;; VSCode bulb for neovim's built-in LSP
                                               ;; (pack :kosayoda/nvim-lightbulb {:config #((setup! :nvim-lightbulb) {:sign {:enabled true :priority 100
                                               ;;                                                                            :autocmd {:enabled true}}})})
                                               ;; Tools for better development in rust using neovim's builtin lsp
                                               ;; (pack :simrat39/rust-tools.nvim {:config #((setup! :rust-tools))})
                                               ;; CompetiTest.nvim is a Neovim plugin to automate testcases management and checking for Competitive Programming
                                               ;; (pack :xeluxee/competitest.nvim {:dependencies [:MunifTanjim/nui.nvim]
                                               ;;                                  :config #((setup! :competitest))})]
                                               ;; Neovim plugin that adds support for file operations using built-in LSP
                                               (pack :antosha417/nvim-lsp-file-operations {:config #((setup! :lsp-file-operations) {})})
                                               ;; Standalone UI for nvim-lsp progress
                                               (pack :j-hui/fidget.nvim {:config #((setup! :fidget) {:text {:spinner "dots"}})})
                                               ;; A neovim plugin that helps managing crates.io dependencies
                                               (pack :saecki/crates.nvim {:config #((setup! :crates))
                                                                          :event "BufRead Cargo.toml"})]
                                :ft ["cpp" "rust" "fennel" "sh" "zsh"]}))

(fn M.config []
  (local lspconfig (require :lspconfig))

  (tset (require :lspconfig.configs) :fennel_language_server {:default_config {:cmd ["/home/alex/.local/bin/fennel-language-server"]
                                                                               :filetypes [:fennel]
                                                                               :single_file_support true
                                                                               :root_dir (lspconfig.util.root_pattern :fnl)
                                                                               :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                                                                                                   :diagnostics {:globals [:vim]}}}}})

  (let [on_attach (fn [client bufnr]
                    ((. (require :lsp-inlayhints) :on_attach) client bufnr)
                    (let [wk (require :which-key)]
                      (wk.register
                        {:l {:name "+LSP"
                             ;; :g {:name "+Jumps"
                             ;;     :D [vim.lsp.buf.declaration "Jumps to declaration of symbol"]
                             ;;     :d [vim.lsp.buf.definition "Jumps to definition of symbol"]}

                             :l {:name "+Lists"
                                 :i [vim.lsp.buf.implementation "Lists all implementations for symbol in quickfix window"]
                                 :r [vim.lsp.buf.references "Lists all references to symbol in quickfix window"]}

                             :K [vim.lsp.buf.hover "Shows hover info about symbol in floating window"]
                             :<C-k> [vim.lsp.buf.signature_help "Shows signature info about symbol in floating window"]

                             :d [vim.lsp.buf.type_definition "Jumps to definition of type of symbol"]
                             :r [vim.lsp.buf.rename "Renames all references to symbol"]
                             :a [vim.lsp.buf.code_action "Code action"]

                             :f [#(vim.lsp.buf.format {:async true}) "Formats buffer using attached (and optionally filtered) language server clients"]}}
                        {:prefix "<localleader>"
                         :buffer bufnr
                         :silent true
                         :noremap true})))
        lsp_flags {:debounce_text_changes 150}]

    ;; (lspconfig.clangd.setup {:on_attach on_attach
    ;;                          :flags lsp_flags})

    (lspconfig.ccls.setup
      {:on_attach on_attach
       :flags lsp_flags
       :init_options {:compilationDatabaseDirectory "build"
                      :index {:threads 0}}
       :clang {}})

    (lspconfig.rust_analyzer.setup
      {:on_attach on_attach
       :flags lsp_flags})
       ;; :cmd ["rustup which --toolchain stable rust-analyzer"]})

    (lspconfig.bashls.setup
      {:filetypes [:sh :zsh]
       :on_attach on_attach
       :flags lsp_flags
       :cmd ["node" "/usr/bin/bash-language-server" "start"]})

    (lspconfig.fennel_language_server.setup
      {:filetypes [:fennel]
       :on_attach on_attach
       :flags lsp_flags})))

M
