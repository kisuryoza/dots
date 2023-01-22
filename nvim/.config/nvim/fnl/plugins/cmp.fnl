(import-macros {: pack} :macros)

(local M
  (pack :hrsh7th/nvim-cmp {:dependencies [:hrsh7th/cmp-nvim-lsp
                                          :hrsh7th/cmp-buffer
                                          :hrsh7th/cmp-path
                                          :hrsh7th/cmp-cmdline
                                          :saadparwaiz1/cmp_luasnip]}))

(fn M.config []
  (local cmp (require :cmp))
  (local luasnip (require :luasnip))

  (set vim.opt.completeopt "menu,menuone,noselect")

  (local cmp_kinds {:Text "  "
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

  (cmp.setup
    {:snippet {:expand (fn [args]
                         ((. luasnip :lsp_expand) args.body))}

     :window {:completion (cmp.config.window.bordered)
              :documentation (cmp.config.window.bordered)}

     :mapping (cmp.mapping.preset.insert {:<C-b> (cmp.mapping.scroll_docs -4)
                                          :<C-f> (cmp.mapping.scroll_docs 4)
                                          :<C-k> (cmp.mapping.select_prev_item)
                                          :<C-j> (cmp.mapping.select_next_item)
                                          :<Tab> (cmp.mapping (fn [fallback]
                                                                (if (cmp.visible)
                                                                  (let [entry (cmp.get_selected_entry)]
                                                                    (if (not entry)
                                                                      (cmp.select_next_item {:behavior cmp.SelectBehavior.Select})
                                                                      (cmp.confirm)))
                                                                  ;(luasnip.expand_or_jumpable)
                                                                  ;(luasnip.expand_or_jump)
                                                                  (fallback))))})

     :sources (cmp.config.sources [{:name "nvim_lsp"}
                                   {:name "path"}
                                   {:name "luasnip"}
                                   {:name "crates"}
                                   {:name "orgmode"}]
                                  [{:name "buffer"}])

     :formatting {:format (fn [_ vim_item]
                            (set vim_item.kind (.. (or (. cmp_kinds vim_item.kind) "") vim_item.kind))
                            vim_item)}}
    (cmp.setup.cmdline
      ":"
      {:mapping (cmp.mapping.preset.cmdline)
       :sources (cmp.config.sources [{:name "path"}]
                                    [{:name "cmdline"}])})))

M
