(import-macros {: pack} :macros)

(local M (pack :anuvyklack/hydra.nvim))

(fn M.config []
  (fn toggle-opt [option on off]
    (var curr_value (: (. vim.opt option) :get))
    (if (= (type curr_value) :table)
        (set curr_value (. curr_value (next curr_value))))
    (vim.print curr_value)
    (if (= curr_value on)
        (tset vim.opt option off)
        (tset vim.opt option on)))

  (let [hydra (require :hydra)]
    (hydra {:name "Window managment"
            :config {:invoke_on_body true}
            :mode :n
            :body :<C-w><C-w>
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
                    ["=" :<C-w>2=]
                    ["+" :<C-w>2+]
                    ["-" :<C-w>2-]
                    [">" :<C-w>2>]
                    ["<" :<C-w>2<]]})
    (local hint "
      _v_ %{ve} virtual edit
      _i_ %{list} invisible characters
      _s_ %{spell} spell
      _w_ %{wrap} wrap
      _c_ %{cul} cursor line
      _n_ %{nu} number
      _r_ %{rnu} relative number")
    (hydra {:name :Options
            : hint
            :config {:color :amaranth
                     :hint {:border :rounded :position :middle}
                     :invoke_on_body true}
            :mode [:n :x]
            :body :<leader>o
            :heads [[:n #(toggle-opt :number true false) {:desc :number}]
                    [:r #(toggle-opt :relativenumber true false) {:desc :relativenumber}]
                    [:v #(toggle-opt :virtualedit :all :block) {:desc :virtualedit}]
                    [:i #(toggle-opt :list true false) {:desc "show invisible"}]
                    [:s #(toggle-opt :spell true false) {:desc :spell}]
                    [:w #(toggle-opt :wrap true false) {:desc :wrap}]
                    [:c #(toggle-opt :cursorline true false) {:desc "cursor line"}]
                    [:<Esc> nil {:exit true}]]})))

;; (hydra {:name "Draw diagrams"
;;         :config {:foreign_keys :run}
;;         :invoke_on_body true
;;         :mode :n
;;         :body :<localleader>D
;;         :heads [[:H "<C-v>h:VBox<CR>"]
;;                 [:J "<C-v>j:VBox<CR>"]
;;                 [:K "<C-v>k:VBox<CR>"]
;;                 [:L "<C-v>l:VBox<CR>"]
;;                 [:f ":VBox<CR>" {:mode :v}]]})))

M
