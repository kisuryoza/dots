(require-macros :macros)

(local M
       (pack :neovim/nvim-lspconfig
             {:dependencies [(pack :j-hui/fidget.nvim {:opts {:notification {:window {:winblend 0}}}})
                             (pack :lvimuser/lsp-inlayhints.nvim
                                   {:opts {:inlay_hints {:type_hints {:prefix "=> "
                                                                      :remove_colon_start true}
                                                         :highlight :Comment}}})]
              :event :VeryLazy}))

(fn M.config []
  (vim.fn.sign_define :DiagnosticSignError
                      {:text " " :texthl :DiagnosticSignError})
  (vim.fn.sign_define :DiagnosticSignWarn
                      {:text " " :texthl :DiagnosticSignWarn})
  (vim.fn.sign_define :DiagnosticSignInfo
                      {:text " " :texthl :DiagnosticSignInfo})
  (vim.fn.sign_define :DiagnosticSignHint
                      {:text "" :texthl :DiagnosticSignHint})

  ; (fn code-action-listener []
  ;   "Used by lsp-CodeAction (heirline's widget)"
  ;   (local context {:diagnostics (vim.lsp.diagnostic.get_line_diagnostics)})
  ;   (local params (vim.lsp.util.make_range_params))
  ;   (set params.context context)
  ;   (vim.lsp.buf_request_all 0 :textDocument/codeAction params
  ;                            (fn [result] ; (print (vim.inspect result))
  ;                              (var has_actions false)
  ;                              (each [_k v (pairs result)]
  ;                                (local result (. v :result))
  ;                                (when (and result
  ;                                           (not (vim.tbl_isempty result)))
  ;                                  (set has_actions true)))
  ;                              (if has_actions
  ;                                  (set vim.g.myvarLspCodeAction true)
  ;                                  (set vim.g.myvarLspCodeAction false)))))
  ;
  ; (vim.api.nvim_create_autocmd [:CursorHold :CursorHoldI]
  ;                              {:pattern ["*"]
  ;                               :callback #(code-action-listener)})
  (local lspconfig (require :lspconfig))

  (fn lsp-on-attach [ev]
    (when (and ev.data ev.data.client_id)
      (local client (vim.lsp.get_client_by_id ev.data.client_id))
      ((. (require :lsp-inlayhints) :on_attach) client ev.buf))
    (let [lsp vim.lsp.buf]
      (nmapp! :lD lsp.declaration :Declaration ev.buf)
      (nmapp! :ld (cmd! "Telescope lsp_definitions") :Definition ev.buf)
      (nmapp! :lK lsp.hover "Hover documentation" ev.buf)
      (nmapp! :li lsp.implementation :Implementation ev.buf)
      (nmapp! :l<C-k> lsp.signature_help "Signature documentation" ev.buf)
      (nmapp! :lt lsp.type_definition "Type definition" ev.buf)
      (nmapp! :lr lsp.rename :Rename ev.buf)
      (nmapp! :lR (cmd! "Telescope lsp_references") :References ev.buf)
      (nmapp! :lf #(lsp.format {:async true}) :Format ev.buf)
      (nmapp! :lwa lsp.add_workspace_folder "Workspace Add Folder" ev.buf)
      (nmapp! :lwr lsp.remove_workspace_folder "Workspace Remove Folder" ev.buf)
      (nmapp! :lwl #(print (vim.inspect (lsp.list_workspace_folders)))
              "Workspace List Folders" ev.buf)))

  (vim.api.nvim_create_augroup :UserLspConfig {})
  (vim.api.nvim_create_autocmd :LspAttach
                               {:callback (fn [args] (lsp-on-attach args))
                                :group :UserLspConfig})
  (let [capabilities ((. (require :cmp_nvim_lsp) :default_capabilities))]
    (lspconfig.clangd.setup {: capabilities})
    ;; (lspconfig.ccls.setup {: capabilities
    ;;                        :init_options {:compilationDatabaseDirectory :target
    ;;                                       :index {:threads 0}}
    ;;                        :clang {}})
    (lspconfig.rust_analyzer.setup {: capabilities
                                    :settings {:rust-analyzer {:check {:command :clippy}}}
                                    :cmd [:rustup :run :stable :rust-analyzer]})
    (lspconfig.bashls.setup {: capabilities})
    (lspconfig.tsserver.setup {: capabilities})
    (lspconfig.nil_ls.setup {: capabilities})))

M

