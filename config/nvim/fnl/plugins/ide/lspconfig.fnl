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
                               ;; helps managing crates.io dependencies
                               (pack :saecki/crates.nvim
                                     {:config #((setup! :crates))
                                      :event "BufRead Cargo.toml"})]
                :ft [:cpp :rust :fennel :sh :nix]}))

(fn M.config []
  (vim.fn.sign_define :DiagnosticSignError
                      {:text " " :texthl :DiagnosticSignError})
  (vim.fn.sign_define :DiagnosticSignWarn
                      {:text " " :texthl :DiagnosticSignWarn})
  (vim.fn.sign_define :DiagnosticSignInfo
                      {:text " " :texthl :DiagnosticSignInfo})
  (vim.fn.sign_define :DiagnosticSignHint
                      {:text "" :texthl :DiagnosticSignHint})

  ;; Used by lsp-CodeAction (heirline's widget)
  (fn code-action-listener []
    (let [context {:diagnostics (vim.lsp.diagnostic.get_line_diagnostics)}
          params (vim.lsp.util.make_range_params)]
      (set params.context context)
      (vim.lsp.buf_request_all 0 :textDocument/codeAction params
                               (fn [result]
                                 ;; (print (vim.inspect result))
                                 (var has_actions false)
                                 (each [_client_id request_result (pairs result)]
                                   (when (and (. request_result :result)
                                              (not (vim.tbl_isempty (. request_result
                                                                       :result))))
                                     (set has_actions true)))
                                 (if has_actions
                                     (set vim.g.myvarLspCodeAction true)
                                     (set vim.g.myvarLspCodeAction false))))))

  (vim.api.nvim_create_autocmd [:CursorHold :CursorHoldI]
                               {:pattern ["*"]
                                :callback #(code-action-listener)})

  (local lspconfig (require :lspconfig))
  (tset (require :lspconfig.configs) :fennel_language_server
        {:default_config {:cmd [(.. (vim.fn.expand "~")
                                    :/.local/bin/fennel-language-server)]
                          :filetypes [:fennel]
                          :single_file_support true
                          :root_dir (lspconfig.util.root_pattern :fnl)
                          :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                                              :diagnostics {:globals [:vim]}}}}})

  (vim.api.nvim_create_autocmd :LspAttach
                               {:callback (fn [args]
                                            (fn inlayhints [args]
                                              (when (not (and args.data args.data.client_id)) (lua "return "))
                                              (local bufnr args.buf)
                                              (local client (vim.lsp.get_client_by_id args.data.client_id))
                                              ((. (require :lsp-inlayhints) :on_attach) client bufnr))
                                            (inlayhints args)
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
                                                                    "Rename all references"]
                                                                :K [vim.lsp.buf.hover
                                                                    "Hover info about symbol"]
                                                                :<C-k> [vim.lsp.buf.signature_help
                                                                        "Show signature info about symbol"]
                                                                :a [vim.lsp.buf.code_action
                                                                    "Code actions"]
                                                                :f [#(vim.lsp.buf.format {:async true})
                                                                    "Format buffer"]}}
                                                           {:prefix :<leader>
                                                            :buffer args.buf
                                                            :silent true
                                                            :noremap true})))
                                :group (vim.api.nvim_create_augroup :UserLspConfig
                                                                    {})})
  (let [capabilities ((. (require :cmp_nvim_lsp) :default_capabilities))]
    ;; (lspconfig.clangd.setup {: capabilities})
    (lspconfig.ccls.setup {: capabilities
                           :init_options {:compilationDatabaseDirectory :build
                                          :index {:threads 0}}
                           :clang {}})
    (lspconfig.rust_analyzer.setup {: capabilities
                                    :settings {:rust-analyzer {:checkOnSave {:command :clippy}}}
                                    :cmd [:rustup :run :stable :rust-analyzer]})
    (lspconfig.fennel_language_server.setup {: capabilities})))

M
