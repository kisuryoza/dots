(import-macros {: pack} :macros)

(local M (pack :nvim-telescope/telescope.nvim
               {:dependencies [:nvim-lua/plenary.nvim]}))

(fn M.config []
  (let [telescope (require :telescope)
        actions (require :telescope.actions)]
    (var t {})
    (set t.defaults {:mappings {:i {:<esc> actions.close}}})
    (telescope.setup t)))

M

