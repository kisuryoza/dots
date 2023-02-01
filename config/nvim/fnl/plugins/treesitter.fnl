(import-macros {: pack} :macros)

(local M (pack :nvim-treesitter/nvim-treesitter
               {:dependencies [:nvim-treesitter/nvim-treesitter-textobjects
                               :nvim-treesitter/nvim-treesitter-refactor
                               :nvim-treesitter/nvim-treesitter-context
                               :mrjones2014/nvim-ts-rainbow]
                :build ":TSUpdate"}))

(fn M.config []
  (let [treesitter (require :nvim-treesitter.configs)]
    (var t {})
    (set t
         {:ensure_installed [:c :cpp :bash :lua :fennel :rust :scss :regex :markdown :markdown_inline]
          :auto_install true
          :ignore_install []
          :highlight {:enable true}
          :incremental_selection {:enable true
                                  :keymaps {:init_selection :<CR>
                                            :node_incremental :<CR>
                                            :scope_incremental :<S-CR>
                                            :node_decremental :<BS>}}})
    ;; nvim-treesitter/nvim-treesitter-textobjects
    (set t.textobjects
         {:enable true
          :select {:enable true
                   :lookahead true
                   :keymaps {:aa {:query "@parameter.outer"
                                  :desc "Outer part of parameter"}
                             :ia {:query "@parameter.inner"
                                  :desc "Inner part of parameter"}
                             :af {:query "@function.outer"
                                  :desc "Outer part of func"}
                             :if {:query "@function.inner"
                                  :desc "Inner part of func"}
                             :ac {:query "@class.outer"
                                  :desc "Outer part of class"}
                             :ic {:query "@class.inner"
                                  :desc "Inner part of class"}}}
          :swap {:enable true
                 :swap_next {:<localleader>csn "@parameter.inner"}
                 :swap_previous {:<localleader>csp "@parameter.inner"}}
          :move {:enable true
                 :set_jumps true
                 :goto_next_start {"]m" {:query "@function.outer"
                                         :desc "Next func start"}
                                   "]]" {:query "@class.outer"
                                         :desc "Next class start"}
                                   "]s" {:query "@statement.outer"
                                         :desc "Next statement"}}
                 :goto_next_end {"]M" {:query "@function.outer"
                                       :desc "Next func end"}
                                 "][" {:query "@class.outer"
                                       :desc "Next class end"}}
                 :goto_previous_start {"[m" {:query "@function.outer"
                                             :desc "Prev func start"}
                                       "[[" {:query "@class.outer"
                                             :desc "Prev class start"}
                                       "[s" {:query "@statement.outer"
                                             :desc "Prev statement"}}
                 :goto_previous_end {"[M" {:query "@function.outer"
                                           :desc "Prev func end"}
                                     "[]" {:query "@class.outer"
                                           :desc "Prev class end"}}}})
    ;; nvim-treesitter/nvim-treesitter-refactor
    (set t.refactor
         {:highlight_definitions {:enable true :clear_on_cursor_move true}
          :highlight_current_scope {:enable false}
          :smart_rename {:enable true
                         :keymaps {:smart_rename :<localleader>cr}}
          :navigation {:enable false
                       :keymaps {:goto_definition :gnd
                                 :list_definitions :gnD
                                 :list_definitions_toc :gO
                                 :goto_next_usage :<a-*>
                                 :goto_previous_usage "<a-#>"}}})
    ;; mrjones2014/nvim-ts-rainbow
    (set t.rainbow {:enable true :extended_mode true :max_file_lines nil})
    (treesitter.setup t)))

M

