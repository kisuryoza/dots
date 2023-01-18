(import-macros {: pack} :macros)

(local M
  (pack :nvim-neo-tree/neo-tree.nvim {:dependencies ["nvim-lua/plenary.nvim"
                                                     "nvim-tree/nvim-web-devicons"
                                                     "MunifTanjim/nui.nvim"]}))

(fn M.config []
  (let [tree (require :neo-tree)]
    (tree.setup
      {:event_handlers [{:event "file_opened"
                         :handler (fn [_file_path]
                                    (tree.close_all))}]})))

M
