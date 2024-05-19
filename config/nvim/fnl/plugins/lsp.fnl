(require-macros :macros)

(local lsp (pack :neovim/nvim-lspconfig
                 {:dependencies [(pack :j-hui/fidget.nvim
                                       {:opts {:notification {:window {:winblend 0}}}})]
                  :event :VeryLazy}))

(fn lsp.config []
  (local lspconfig (require :lspconfig))

  (fn lsp-on-attach [ev]
    (let [lsp vim.lsp.buf]
      (nmapp! :lD lsp.declaration :Declaration ev.buf)
      (nmapp! :ld (cmd! "Telescope lsp_definitions") :Definition ev.buf)
      (nmapp! :li lsp.implementation :Implementation ev.buf)
      (nmapp! :l<C-k> lsp.signature_help "Signature documentation" ev.buf)
      (nmapp! :lt lsp.type_definition "Type definition" ev.buf)
      (nmapp! :lr lsp.rename :Rename ev.buf)
      (nmapp! :lR (cmd! "Telescope lsp_references") :References ev.buf) ; (nmapp! :lf #(lsp.format {:async true}) :Format ev.buf)
      (nmapp! :lh
              #(vim.lsp.inlay_hint.enable (not vim.lsp.inlay_hint.is_enabled))
              :Rename ev.buf)
      (nmapp! :lwa lsp.add_workspace_folder "Workspace Add Folder" ev.buf)
      (nmapp! :lwr lsp.remove_workspace_folder "Workspace Remove Folder" ev.buf)
      (nmapp! :lwl #(print (vim.inspect (lsp.list_workspace_folders)))
              "Workspace List Folders" ev.buf)))

  (vim.api.nvim_create_autocmd :LspAttach
                               {:group (vim.api.nvim_create_augroup :UserLspConfig
                                                                    {:clear true})
                                :callback (fn [args] (lsp-on-attach args))})
  (let [capabilities ((. (require :cmp_nvim_lsp) :default_capabilities))]
    (lspconfig.clangd.setup {: capabilities})
    (lspconfig.rust_analyzer.setup {: capabilities
                                    :settings {:rust-analyzer {:check {:command :clippy}}}
                                    :cmd [:rustup :run :stable :rust-analyzer]})
    (lspconfig.bashls.setup {: capabilities})
    (lspconfig.lua_ls.setup {: capabilities
                             :settings {:Lua {:runtime {:version :LuaJIT}
                                              :workspace {:checkThirdParty false
                                                          :library [vim.env.VIMRUNTIME]}
                                              :format {:enable false}
                                              :telemetry {:enable false}}}})
    (lspconfig.nil_ls.setup {: capabilities})))

(local lint (pack :mfussenegger/nvim-lint {:event :VeryLazy}))

(fn lint.config []
  (local lint (require :lint))
  (set lint.linters_by_ft {:lua [:selene] :sh [:shellcheck] :nix [:statix]})
  (vim.api.nvim_create_autocmd [:BufWritePost :BufEnter]
                               {:group (vim.api.nvim_create_augroup :Linting
                                                                    {:clear true})
                                :callback (fn [] (lint.try_lint))}))

(local conform (pack :stevearc/conform.nvim
                     {:config (fn []
                                (local conform (require :conform))
                                (conform.setup {:formatters_by_ft {:lua [:stylua]
                                                                   :rust [:rustfmt]
                                                                   :sh [:shfmt
                                                                        :shellharden]
                                                                   :nix [:alejandra]
                                                                   :markdown [:prettier]
                                                                   :yaml [:prettier]
                                                                   :json [:jq]
                                                                   :fennel [:fnlfmt]}})
                                (set conform.formatters.shfmt
                                     {:prepend_args [:-i :4]})
                                (vim.keymap.set :n :<leader>cf
                                                #(conform.format {:async true
                                                                  :lsp_fallback true})
                                                {:remap true
                                                 :desc "Format buffer"}))
                      :event :VeryLazy}))

(local mason_tools [:codelldb
                    :lua-language-server
                    :selene
                    :stylua
                    :bash-language-server
                    :shellcheck
                    :shfmt
                    :shellharden
                    :prettier])

(local mason (pack :williamboman/mason.nvim
                   {:dependencies (pack :WhoIsSethDaniel/mason-tool-installer.nvim
                                        {:opts {:ensure_installed mason_tools}})
                    :config true}))

[lsp lint conform mason]

