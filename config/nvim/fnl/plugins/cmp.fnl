(import-macros {: pack} :macros)

(local M (pack :hrsh7th/nvim-cmp
               {:dependencies [:hrsh7th/cmp-nvim-lsp
                               :hrsh7th/cmp-buffer
                               :hrsh7th/cmp-path
                               :hrsh7th/cmp-cmdline
                               :L3MON4D3/LuaSnip
                               :saadparwaiz1/cmp_luasnip
                               :rafamadriz/friendly-snippets]}))

(fn M.config []
  (local cmp (require :cmp))
  (local luasnip (require :luasnip))
  ((. (require :luasnip.loaders.from_vscode) :lazy_load))
  (luasnip.config.setup {:history false} :update_events :InsertLeave
                        :region_check_events
                        "CursorMoved,CursorHold,InsertEnter"
                        :delete_check_events :InsertEnter)
  (let [wk (require :which-key)]
    (wk.register {:<C-L> [#(luasnip.jump 1) ""] :<C-H> [#(luasnip.jump -1) ""]}
                 {:mode :i :silent true})
    (wk.register {:<C-L> [#(luasnip.jump 1) ""] :<C-H> [#(luasnip.jump -1) ""]}
                 {:mode :s :silent true}))
  (vim.cmd "imap <silent><expr> <C-S> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''")
  (vim.cmd "smap <silent><expr> <C-S> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''")
  (set vim.opt.completeopt "menu,menuone,noselect")
  (local kind-icons {:Text "  "
                     :Method "  "
                     :Function "  "
                     :Constructor "  "
                     :Field "  "
                     :Variable "  "
                     :Class "  "
                     :Interface "  "
                     :Module "  "
                     :Property "  "
                     :Unit "  "
                     :Value "  "
                     :Enum "  "
                     :Keyword "  "
                     :Snippet "  "
                     :Color "  "
                     :File "  "
                     :Reference "  "
                     :Folder "  "
                     :EnumMember "  "
                     :Constant "  "
                     :Struct "  "
                     :Event "  "
                     :Operator "  "
                     :TypeParameter "  "})
  (var t {})
  (set t.snippet
       {:expand (fn [args]
                  ((. luasnip :lsp_expand) args.body))})
  (set t.mapping
       (cmp.mapping.preset.insert {:<C-b> (cmp.mapping.scroll_docs -4)
                                   :<C-f> (cmp.mapping.scroll_docs 4)
                                   :<C-k> (cmp.mapping.select_prev_item)
                                   :<C-j> (cmp.mapping.select_next_item)
                                   :<Tab> (cmp.mapping (fn [fallback]
                                                         (if (cmp.visible)
                                                             (let [entry (cmp.get_selected_entry)]
                                                               (if (not entry)
                                                                   (cmp.select_next_item {:behavior cmp.SelectBehavior.Select})
                                                                   (cmp.confirm)))
                                                             ;; (luasnip.expand_or_jumpable)
                                                             ;; (luasnip.expand_or_jump)
                                                             (fallback))))}))
  (set t.sources (cmp.config.sources [{:name :nvim_lsp}
                                      {:name :path}
                                      {:name :crates}
                                      {:name :neorg}
                                      {:name :luasnip}
                                      {:name :buffer}]))
  (set t.formatting {:format (fn [_entry vim-item]
                               (set vim-item.kind
                                    (.. (or (. kind-icons vim-item.kind) "")
                                        vim-item.kind))
                               vim-item)})
  (cmp.setup t)
  (cmp.setup.cmdline ":"
                     {:mapping (cmp.mapping.preset.cmdline)
                      :sources (cmp.config.sources [{:name :path}]
                                                   [{:name :cmdline}])}))

M
