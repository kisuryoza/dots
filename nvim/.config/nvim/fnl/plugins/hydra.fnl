(import-macros {: pack} :macros)

(local M
  (pack :anuvyklack/hydra.nvim))

(fn M.config []
  (let [hydra (require :hydra)]
    (hydra {:name "Window managment"
            :config {:invoke_on_body true}
            :mode :n
            :body "<C-w><C-w>"
            :heads [[:h :<C-w>h]
                    [:j :<C-w>j]
                    [:k :<C-w>k]
                    [:l :<C-w>l]

                    [:w :<C-w>w]
                    [:x :<C-w>x]
                    [:c :<C-w>c]
                    [:q :<C-w>q]

                    [:s :<C-w>s]
                    [:v :<C-w>v]

                    [:= :<C-w>=]
                    [:+ :<C-w>+]
                    [:- :<C-w>-]
                    [:> :<C-w>>]
                    [:< :<C-w><]]})

    (hydra {:name "Draw diagrams"
            :config {:foreign_keys :run}
                    :invoke_on_body true
            :mode :n
            :body "<localleader>D"
            :heads [[:H "<C-v>h:VBox<CR>"]
                    [:J "<C-v>j:VBox<CR>"]
                    [:K "<C-v>k:VBox<CR>"]
                    [:L "<C-v>l:VBox<CR>"]
                    [:f ":VBox<CR>" {:mode :v}]]})))

M
