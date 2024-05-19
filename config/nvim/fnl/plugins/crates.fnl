(require-macros :macros)

(local M (pack :saecki/crates.nvim
               {:dependencies [:nvim-lua/plenary.nvim]
                :event "BufRead Cargo.toml"}))

(fn on_attach [_client bufnr]
  (local crates (require :crates))
  (nmapp! :Cp crates.show_popup "Crates: Show popup" bufnr)
  (nmapp! :Cf crates.show_features_popup "Crates: Features" bufnr)
  (nmapp! :Cd crates.show_dependencies_popup "Crates: Dependencies" bufnr))

(fn M.config []
  (local crates (require :crates))
  (crates.setup {:lsp {:enabled true
                       : on_attach
                       :actions true
                       :completion true
                       :hover true}}))

M

