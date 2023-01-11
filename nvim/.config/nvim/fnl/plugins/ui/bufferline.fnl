(import-macros {: pack} :macros)

(local M
  (pack :akinsho/bufferline.nvim {:version "^3"}))

(fn M.config []
  (local bufferline (require :bufferline))

  (let [selected {:bold true
                  :italic false}
        selected-second {:bold false
                         :italic true}]
    (bufferline.setup
      {:options {; :numbers "buffer_id"
                 :diagnostics "nvim_lsp"
                 :diagnostics_indicator (fn [count level diagnostics_dict context]
                                          (let [icon (if (= level "error")
                                                         " "
                                                         (= level "warning")
                                                         " "
                                                         "")]
                                            (.. " " icon count)))
                 :offsets [{:filetype "NvimTree"
                            :text "File Explorer"
                            :text_align "left"
                            :separator true}]
                 :color_icons false
                 :show_buffer_icons true
                 :show_buffer_close_icons false
                 :show_close_icon false
                 :show_tab_indicators true
                 :separator_style :thin
                 :always_show_bufferline false
                 :sort_by "tabs"}
       :highlights {
                    ;; :fill default ; tabline background
                    ;; :background {:bg colors.bg :fg colors.fg} ; inactive tabs
                    ;; :tab default
                    :tab_selected selected
                    :tab_close selected

                    ;; :close_button default
                    :close_button_visible selected-second
                    :close_button_selected selected

                    :buffer_visible selected-second
                    :buffer_selected selected

                    ;; :numbers default
                    :numbers_visible selected-second
                    :numbers_selected selected

                    :modified_visible selected-second
                    :modified_selected selected

                    ;; :separator default
                    :separator_visible selected-second
                    :separator_selected selected

                    ;; :pick default
                    :pick_visible selected-second
                    :pick_selected selected}})))

                    ;; :offset_separator default}})))

M
