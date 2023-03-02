(import-macros {: pack} :macros)

(local M (pack :folke/noice.nvim {:dependencies [:MunifTanjim/nui.nvim]}))

(fn M.config []
  (let [noice (require :noice)]
    (var t {})
    (set t.lsp {:override {:vim.lsp.util.convert_input_to_markdown_lines true
                           :vim.lsp.util.stylize_markdown true
                           :cmp.entry.get_documentation true}})
    (set t.presets {:bottom_search true
                    :command_palette true
                    :long_message_to_split true
                    :inc_rename false
                    :lsp_doc_border false})
    (set t.views
         {:cmdline_popup {:border {:style :none :padding [1 3]}
                          :filter_options {}
                          :win_options {:winhighlight "NormalFloat:NormalFloat,FloatBorder:FloatBorder"}}})
    ;; (set t.routes [{:filter {:event :msg_show :kind "" :find :written}
    ;;                 :opts {:skip true}}])
    (noice.setup t)))

M

