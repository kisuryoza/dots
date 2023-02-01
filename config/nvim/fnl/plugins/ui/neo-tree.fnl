(import-macros {: pack} :macros)

(local M (pack :nvim-neo-tree/neo-tree.nvim
               {:dependencies [:nvim-lua/plenary.nvim
                               :nvim-tree/nvim-web-devicons
                               :MunifTanjim/nui.nvim]}))

(fn M.config []
  (vim.cmd "let g:neo_tree_remove_legacy_commands = 1")
  (let [tree (require :neo-tree)
        manager (require :neo-tree.sources.manager)]
    (var t {})
    (set t.event_handlers
         [{:event :file_opened
           :handler (fn [_file_path]
                      (manager.close_all))}])
    (tree.setup t)))

M

