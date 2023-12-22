(import-macros {: pack : map!} :macros)

(local M (pack :hrsh7th/nvim-cmp
               {:dependencies [:hrsh7th/cmp-nvim-lsp
                               :hrsh7th/cmp-buffer
                               :hrsh7th/cmp-cmdline
                               :FelipeLema/cmp-async-path
                               :L3MON4D3/LuaSnip
                               :saadparwaiz1/cmp_luasnip
                               :rafamadriz/friendly-snippets]
                :event :VeryLazy}))

(fn M.config []
  (local cmp (require :cmp))
  (local luasnip (require :luasnip))
  ((. (require :luasnip.loaders.from_vscode) :lazy_load))
  (luasnip.setup {:history false
                  :update_events [:TextChanged :TextChangedI]
                  :region_check_events [:CursorMoved :CursorMovedI]
                  :delete_check_events [:TextChanged :TextChangedI]})
  (map! :i :<C-K> #(luasnip.expand))
  (map! [:i :s] :<C-L> #(when (luasnip.locally_jumpable 1) (luasnip.jump 1)))
  (map! [:i :s] :<C-J> #(when (luasnip.locally_jumpable -1) (luasnip.jump -1)))
  (map! [:i :s] :<C-E>
        #(when (luasnip.choice_active) (luasnip.change_choice 1)))
  (set vim.opt.completeopt "menu,menuone,noselect")
  (local kind-icons {:Text ""
                     :Method "󰆧"
                     :Function "󰊕"
                     :Constructor ""
                     :Field "󰇽"
                     :Variable "󰂡"
                     :Class "󰠱"
                     :Interface ""
                     :Module ""
                     :Property "󰜢"
                     :Unit ""
                     :Value "󰎠"
                     :Enum ""
                     :Keyword "󰌋"
                     :Snippet ""
                     :Color "󰏘"
                     :File "󰈙"
                     :Reference ""
                     :Folder "󰉋"
                     :EnumMember ""
                     :Constant "󰏿"
                     :Struct ""
                     :Event ""
                     :Operator "󰆕"
                     :TypeParameter "󰅲"})
  (var t {})
  (set t.snippet
       {:expand (fn [args]
                  ((. luasnip :lsp_expand) args.body))})
  (set t.mapping {:<C-b> (cmp.mapping.scroll_docs -4)
                  :<C-f> (cmp.mapping.scroll_docs 4)
                  :<C-k> (cmp.mapping.select_prev_item)
                  :<C-j> (cmp.mapping.select_next_item)
                  :<Tab> (cmp.mapping (fn [fallback]
                                        (if (cmp.visible)
                                            (let [entry (cmp.get_selected_entry)]
                                              (if (not entry)
                                                  (cmp.select_next_item {:behavior cmp.SelectBehavior.Select})
                                                  (cmp.confirm)))
                                            (luasnip.expand_or_locally_jumpable)
                                            (luasnip.expand_or_jump)
                                            (fallback)))
                                      [:i :s :c])})
  (set t.sources
       (cmp.config.sources [{:name :nvim_lsp} {:name :luasnip}]
                           [{:name :async_path}]
                           [{:name :buffer} {:name :crates}]))
  (set t.window {:completion {:col_offset -3}})
  (set t.formatting {:format (fn [_entry vim-item]
                               ; (when (not= vim-item.menu nil)
                               ;   (set vim-item.menu
                               ;        (string.sub vim-item.menu 1 25)))
                               (let [kind vim-item.kind
                                     icon (. kind-icons kind)]
                                 (set vim-item.kind
                                      (if (not= icon nil)
                                          (.. "" icon " ")
                                          "  ")))
                               vim-item)
                     :fields [:kind :abbr :menu]})
  (let [color (vim.api.nvim_get_hl 0 {:name :CmpItemKind})]
    (vim.api.nvim_set_hl 0 :CmpItemMenu {:fg color.fg}))
  (cmp.setup t)
  (cmp.setup.cmdline "/"
                     {:mapping (cmp.mapping.preset.cmdline)
                      :sources (cmp.config.sources [{:name :buffer}])})
  (cmp.setup.cmdline ":"
                     {:mapping (cmp.mapping.preset.cmdline)
                      :sources (cmp.config.sources [{:name :async_path}]
                                                   [{:name :cmdline}])}))

M

