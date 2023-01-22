(import-macros {: pack} :macros)

(local M
  (pack :L3MON4D3/LuaSnip {:dependencies [:rafamadriz/friendly-snippets]}))

(fn M.config []
  ((. (require :luasnip.loaders.from_vscode) :lazy_load))
  (local ls (require :luasnip))
  (ls.config.setup
    {:history false
     :update_events "InsertLeave"
     :region_check_events "CursorMoved,CursorHold,InsertEnter"
     :delete_check_events "InsertEnter"})

  (let [wk (require :which-key)]
    (wk.register
      {:<C-L> [#(ls.jump 1) ""]
       :<C-H> [#(ls.jump -1) ""]}
      {:mode "i"
       :silent true})
    (wk.register
      {:<C-L> [#(ls.jump 1) ""]
       :<C-H> [#(ls.jump -1) ""]}
      {:mode "s"
       :silent true}))
  (vim.cmd "imap <silent><expr> <C-S> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''")
  (vim.cmd "smap <silent><expr> <C-S> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''"))

M
