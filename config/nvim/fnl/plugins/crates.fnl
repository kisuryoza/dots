(require-macros :macros)

(local M (pack :saecki/crates.nvim
               {:dependencies [:nvim-lua/plenary.nvim]
                :event "BufRead Cargo.toml"}))

(fn M.config []
  (local crates (require :crates))
  (var t {})
  (set t {:lsp {:enabled true
                :on_attach (fn [_client bufnr]
                             (nmapp! :lK vim.lsp.buf "Hover documentation"
                                     bufnr)
                             (nmapp! :Cp crates.show_popup "Crates: Show popup"
                                     bufnr)
                             (nmapp! :Cf crates.show_features_popup
                                     "Crates: Features" bufnr)
                             (nmapp! :Cd crates.show_dependencies_popup
                                     "Crates: Dependencies" bufnr))
                :actions true
                :completion true
                :hover true}})
  (crates.setup t))

M

