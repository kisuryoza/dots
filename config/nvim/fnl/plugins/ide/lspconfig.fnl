(import-macros {: pack : setup! : cmd : nmap} :macros)

(local M
       (pack :neovim/nvim-lspconfig
             {:dependencies [;; renders diagnostics using virtual lines on top of the real line of code
                             {:url "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
                              :config (fn []
                                        ((setup! :lsp_lines))
                                        (vim.diagnostic.config {:virtual_lines {:only_current_line true}}))}
                             ;; implementation of LSP inlay hint
                             (pack :lvimuser/lsp-inlayhints.nvim
                                   {:opts {:inlay_hints {:type_hints {:prefix "=> "
                                                                      :remove_colon_start true}
                                                         :highlight :Comment}}})
                             ;; helps managing crates.io dependencies
                             (pack :saecki/crates.nvim
                                   {:config true :event "BufRead Cargo.toml"})]}))

(fn M.config []
  (vim.fn.sign_define :DiagnosticSignError
                      {:text " " :texthl :DiagnosticSignError})
  (vim.fn.sign_define :DiagnosticSignWarn
                      {:text " " :texthl :DiagnosticSignWarn})
  (vim.fn.sign_define :DiagnosticSignInfo
                      {:text " " :texthl :DiagnosticSignInfo})
  (vim.fn.sign_define :DiagnosticSignHint
                      {:text "" :texthl :DiagnosticSignHint})
  ;; Used by lsp-CodeAction (heirline"s widget)
  ;; (fn code-action-listener []
  ;;   (let [context {:diagnostics (vim.lsp.diagnostic.get_line_diagnostics)}
  ;;         params (vim.lsp.util.make_range_params)]
  ;;     (set params.context context)
  ;;     (vim.lsp.buf_request_all 0 :textDocument/codeAction params
  ;;                              (fn [result]
  ;;                                ;; (print (vim.inspect result))
  ;;                                (var has_actions false)
  ;;                                (each [_client_id request_result (pairs result)]
  ;;                                  (when (and (. request_result :result)
  ;;                                             (not (vim.tbl_isempty (. request_result
  ;;                                                                      :result))))
  ;;                                    (set has_actions true)))
  ;;                                (if has_actions
  ;;                                    (set vim.g.myvarLspCodeAction true)
  ;;                                    (set vim.g.myvarLspCodeAction false))))))
  ;; (vim.api.nvim_create_autocmd [:CursorHold :CursorHoldI]
  ;;                              {:pattern ["*"]
  ;;                               :callback #(code-action-listener)})
  (local lspconfig (require :lspconfig))
  (tset (require :lspconfig.configs) :fennel_language_server
        {:default_config {:cmd [(.. (vim.fn.expand "~")
                                    :/.local/bin/fennel-language-server)]
                          :filetypes [:fennel]
                          :single_file_support true
                          :root_dir (lspconfig.util.root_pattern :fnl)
                          :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                                              :diagnostics {:globals [:vim]}}}}})

  (fn lsp-on-attach [ev]
    (when (and ev.data ev.data.client_id)
      (local client (vim.lsp.get_client_by_id ev.data.client_id))
      ((. (require :lsp-inlayhints) :on_attach) client ev.buf))

    (nmap :<leader>lR (cmd "Telescope lsp_references") :References ev.buf)
    (nmap :<leader>ld (cmd "Telescope lsp_definitions") :Definitions ev.buf)
    (nmap :<leader>lK vim.lsp.buf.hover "Hover Documentation" ev.buf)
    (nmap :<leader>l<C-k> #(vim.lsp.buf.signature_help)
          "Signature Documentation" ev.buf)
    (nmap :<leader>lr vim.lsp.buf.rename :Rename ev.buf)
    (nmap :<leader>la vim.lsp.buf.code_action "Code Actions" ev.buf)
    (nmap :<leader>lf #(vim.lsp.buf.format {:async true}) :Format ev.buf)
    (nmap :<leader>wa vim.lsp.buf.add_workspace_folder "Workspace Add Folder" ev.buf)
    (nmap :<leader>wr vim.lsp.buf.remove_workspace_folder
          "Workspace Remove Folder" ev.buf)
    (nmap :<leader>wl
          #(print (vim.inspect (vim.lsp.buf.list_workspace_folders)))
          "Workspace List Folders" ev.buf))

  (vim.api.nvim_create_augroup :UserLspConfig {})
  (vim.api.nvim_create_autocmd :LspAttach
                               {:callback (fn [args] (lsp-on-attach args))
                                :group :UserLspConfig})
  (let [capabilities ((. (require :cmp_nvim_lsp) :default_capabilities))]
        ;; filename (vim.fn.expand "%:p:t")
        ;; autostart (if (or (= filename :main.rs) (= filename :lib.rs)) true false)]
    (lspconfig.clangd.setup {: capabilities})
    ;; (lspconfig.ccls.setup {: capabilities
    ;;                        :init_options {:compilationDatabaseDirectory :target
    ;;                                       :index {:threads 0}}
    ;;                        :clang {}})
    (lspconfig.rust_analyzer.setup {: capabilities
                                    :settings {:rust-analyzer {:check {:command :clippy}}}
                                    :cmd [:rustup :run :stable :rust-analyzer]
                                    :autostart false})
    (lspconfig.fennel_language_server.setup {: capabilities})
    (lspconfig.tsserver.setup {: capabilities})
    (lspconfig.nil_ls.setup {: capabilities})))

M
