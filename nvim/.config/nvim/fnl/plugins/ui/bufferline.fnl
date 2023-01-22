(import-macros {: pack} :macros)

(local M (pack :akinsho/bufferline.nvim {:version "*"}))

(fn M.config []
  (let [bufferline (require :bufferline)]
    (var t {})
    (set t.options {;; :numbers "buffer_id"
                    :diagnostics :nvim_lsp
                    :diagnostics_indicator (fn [_count
                                                _level
                                                diagnostics_dict
                                                _context]
                                             (var out " ")
                                             (each [e n (pairs diagnostics_dict)]
                                               (let [symbol (if (= e :error)
                                                                " "
                                                                (= e :warning)
                                                                " " " ")]
                                                 (set out (.. out n symbol))))
                                             out)
                    :offsets [{:filetype :NvimTree
                               :text "File Explorer"
                               :text_align :left
                               :separator true}]
                    :color_icons false
                    :show_buffer_icons true
                    :show_buffer_close_icons false
                    :show_close_icon false
                    :show_tab_indicators true
                    :separator_style :thin
                    :always_show_bufferline false
                    :sort_by :tabs})
    (bufferline.setup t)))

M

