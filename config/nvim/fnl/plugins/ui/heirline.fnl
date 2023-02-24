(import-macros {: pack} :macros)

(local M (pack :rebelot/heirline.nvim))

(fn M.config []
  (local heirline (require :heirline))
  (local conditions (require :heirline.conditions))
  (local utils (require :heirline.utils))
  (local devicons (require :nvim-web-devicons))
  (local diag vim.diagnostic)
  (local colors
         {:blue (. (utils.get_highlight :Function) :fg)
          :bg_dim (. (utils.get_highlight :NormalNC) :bg)
          :bright_bg (. (utils.get_highlight :Folded) :bg)
          :bright_fg (. (utils.get_highlight :Folded) :fg)
          :cyan (. (utils.get_highlight :Special) :fg)
          :dark_red (. (utils.get_highlight :DiffDelete) :bg)
          :diag_error (. (utils.get_highlight :DiagnosticError) :fg)
          :diag_hint (. (utils.get_highlight :DiagnosticHint) :fg)
          :diag_info (. (utils.get_highlight :DiagnosticInfo) :fg)
          :diag_warn (. (utils.get_highlight :DiagnosticWarn) :fg)
          :git_add (. (utils.get_highlight :diffAdded) :fg)
          :git_change (. (utils.get_highlight :diffChanged) :fg)
          :git_del (. (utils.get_highlight :diffRemoved) :fg)
          :gray (. (utils.get_highlight :NonText) :fg)
          :green (. (utils.get_highlight :String) :fg)
          :orange (. (utils.get_highlight :Constant) :fg)
          :purple (. (utils.get_highlight :Statement) :fg)
          :red (. (utils.get_highlight :DiagnosticError) :fg)
          :type (. (utils.get_highlight :Type) :fg)
          :TabLineSel (. (utils.get_highlight :TabLineSel) :fg)})
  (local align {:provider "%="})
  (local space {:provider " "})
  (local vim-mode {:init (fn [self]
                           (set self.mode (vim.fn.mode 1))
                           (when (not self.once)
                             (vim.api.nvim_create_autocmd :ModeChanged
                                                          {:command :redrawstatus
                                                           :pattern "*:*o"})
                             (set self.once true)))
                   ; https://neovim.io/doc/user/builtin.html#mode()
                   :static {:modes {:n [:N colors.green]
                                    :v [:V colors.cyan]
                                    :V [:VL colors.cyan]
                                    "\022" [:VB colors.cyan]
                                    :i [:I colors.red]
                                    :R [:R colors.orange]
                                    :Rv [:VR colors.orange]
                                    :c [:C colors.orange]
                                    :nt [:NT colors.green]
                                    :t [:T colors.green]}}
                   :provider (fn [self]
                               (.. " "
                                   (or (?. self.modes self.mode 1) self.mode)
                                   " "))
                   :hl (fn [self]
                         (let [fg (or (?. self.modes self.mode 2) :gray)]
                           {:bold true : fg}))
                   :update [:ModeChanged]})
  (local git {:condition conditions.is_git_repo
              :hl {:fg colors.orange}
              :init (fn [self]
                      (set self.status_dict vim.b.gitsigns_status_dict)
                      (set self.has_changes
                           (or (or (not= self.status_dict.added 0)
                                   (not= self.status_dict.removed 0))
                               (not= self.status_dict.changed 0))))
              1 {:provider (fn [self] (.. "󰘬 " self.status_dict.head))}
              2 {:hl {:fg colors.git_add}
                 :provider (fn [self]
                             (local count (or self.status_dict.added 0))
                             (and (> count 0) (.. " +" count)))}
              3 {:hl {:fg colors.git_del}
                 :provider (fn [self]
                             (local count (or self.status_dict.removed 0))
                             (and (> count 0) (.. " -" count)))}
              4 {:hl {:fg colors.git_change}
                 :provider (fn [self]
                             (local count (or self.status_dict.changed 0))
                             (and (> count 0) (.. " ~" count)))}})
  ;; this is the parent for the file's block
  (local file {:init (fn [self]
                       (let [file (vim.api.nvim_buf_get_name 0)]
                         (set self.file file)))})
  ;; provides file's icon
  (local file-icon {:init (fn [self]
                            (let [file self.file
                                  extension (vim.fn.fnamemodify file ":e")]
                              (set (self.icon self.icon_color)
                                   (devicons.get_icon_color file extension
                                                            {:default true}))))
                    :provider (fn [self]
                                (and self.icon (.. self.icon " ")))
                    :hl (fn [self] {:fg self.icon_color})})
  ;; provides file's name
  (local file-name {:provider (fn [self]
                                (let [path (vim.fn.fnamemodify self.file ":.")]
                                  (if (not= path "")
                                      (if (conditions.width_percent_below (length path)
                                                                          0.25)
                                          path
                                          (vim.fn.pathshorten path 5))
                                      "[No Name]")))})
  ;; provides file's status
  (local file-flags [{:condition (fn [] vim.bo.modified)
                      :hl {:fg colors.green}
                      :provider " ●"}
                     {:condition (fn []
                                   (or (not vim.bo.modifiable) vim.bo.readonly))
                      :hl {:fg colors.orange}
                      :provider " "}])
  (local file (utils.insert file file-icon file-name file-flags))

  (fn diag-count [severity bufnr icon]
    (let [count (vim.tbl_count (diag.get bufnr {: severity}))]
     (when (and count (> count 0))
       (.. " " icon " " count))))

  (local lsp-status {1 {:provider (fn [self]
                                    (let [bufnr (if self.bufnr self.bufnr 0)]
                                     (diag-count diag.severity.ERROR bufnr "")))
                        :hl {:fg colors.diag_error}}
                     2 {:provider (fn [self]
                                    (let [bufnr (if self.bufnr self.bufnr 0)]
                                     (diag-count diag.severity.WARN bufnr "")))
                        :hl {:fg colors.diag_warn}}
                     3 {:provider (fn [self]
                                    (let [bufnr (if self.bufnr self.bufnr 0)]
                                     (diag-count diag.severity.INFO bufnr "")))
                        :hl {:fg colors.diag_info}}
                     4 {:provider (fn [self]
                                    (let [bufnr (if self.bufnr self.bufnr 0)]
                                     (diag-count diag.severity.HINT bufnr "")))
                        :hl {:fg colors.diag_hint}}})
                     ;; :update [:DiagnosticChanged]})
  (local file-encoding
         {:provider (fn []
                      (let [label vim.bo.fileencoding]
                        (and (not= label :utf-8) (label:upper))))})
  (local file-format
         {:provider (fn []
                      (let [label vim.bo.fileformat]
                        (and (not= label :unix) (label:upper))))})
  (local ruler
         {:provider (fn []
                      (let [[line col] (vim.api.nvim_win_get_cursor 0)
                            lines (vim.api.nvim_buf_line_count 0)
                            progress (if (= line 1)
                                         :Top
                                         (= line lines)
                                         :Btm
                                         (.. (math.ceil (* 100 (/ line lines)))
                                             "%%"))]
                        (.. line "/" lines ":" col " " progress)))})
  (local file-type {:provider (fn []
                                (let [label vim.bo.filetype]
                                  (label:upper)))
                    :hl {:fg colors.type}})
  (local no-statusline {:condition (fn []
                                     (conditions.buffer_matches {:buftype [:nofile
                                                                           :prompt
                                                                           :help
                                                                           :quickfix]
                                                                 :filetype [:^git.*
                                                                            :fugitive
                                                                            :alpha]}))
                        1 align})
  (local inactive-statusline {:condition conditions.is_not_active
                              :hl {:bg colors.bg_dim}})
  (local inactive-statusline (utils.insert inactive-statusline git align file align file-encoding file-format space file-type))
  (local active-statusline [vim-mode
                            git
                            align
                            file
                            align
                            lsp-status
                            space
                            file-encoding
                            file-format
                            ruler
                            space
                            file-type])
  (local statusline {:hl {:fg colors.orange}
                     :fallthrough false})
  (local statusline (utils.insert statusline no-statusline inactive-statusline active-statusline))
  ;; Tabline
  ;; provides buffer's number
  (local tabline-bfnr {:hl :Comment :provider (fn [self] (.. self.bufnr "."))})
  ;; provides file's name
  (local tabline-file-name
         {:hl (fn [self]
                {:bold self.is_active :italic self.is_visible})
          :provider (fn [self]
                      (let [file self.file]
                        (if (= file "") "[No Name]"
                            (vim.fn.fnamemodify file ":t"))))})
  ;; provides file's status
  (local tabline-file-flags [{:condition (fn [self]
                                           (not (vim.api.nvim_buf_get_option self.bufnr
                                                                             :modifiable)))
                              :hl {:fg colors.orange}
                              :provider "  "}
                             {:condition (fn [self]
                                           (vim.api.nvim_buf_get_option self.bufnr
                                                                        :modified))
                              :hl {:fg colors.green}
                              :provider " ● "}
                             {:condition (fn [self]
                                           (= (vim.api.nvim_buf_get_option self.bufnr
                                                                           :buftype)
                                              :terminal))
                              :hl {:fg colors.orange}
                              :provider "  "}])
  ;; this is the parent for tabs
  (local bufferline
         {:hl (fn [self] (if self.is_active :TabLineSel :TabLine))
          :init (fn [self]
                  (set self.file (vim.api.nvim_buf_get_name self.bufnr)))
          :on_click {:callback (fn [_ minwid _ button]
                                 (if (= button :r)
                                     (vim.api.nvim_buf_delete minwid
                                                              {:force false})
                                     (vim.api.nvim_win_set_buf 0 minwid)))
                     :minwid (fn [self] self.bufnr)
                     :name :heirline_tabline_buffer_callback}})
  (local bufferline (utils.insert bufferline space tabline-bfnr file-icon tabline-file-name tabline-file-flags lsp-status space))
  ;; (local tabline-buffer-block
  ;;        (utils.surround ["┃" "┃"]
  ;;                        (fn [self]
  ;;                          (if self.is_active
  ;;                              (. (utils.get_highlight :TabLineSel) :bg)
  ;;                              (. (utils.get_highlight :TabLine) :bg)))
  ;;                        [tabline-file-name-block]))
  (local bufferline
         (utils.make_buflist bufferline
                             {:hl {:fg :gray} :provider ""}
                             {:hl {:fg :gray} :provider ""}))
  ;; provides list of tabs
  (local tabpage
         {:hl (fn [self] (if self.is_active :TabLineSel :TabLine))
          :provider (fn [self] (.. "%" self.tabnr "T " self.tabpage " %T"))})
  ;; provides an icon to close current tab
  (local tabpage-close {:hl :TabLine :provider "%999X  %X"})
  (local tab-pages
         {1 align
          2 (utils.make_tablist tabpage)
          3 tabpage-close
          :condition #(>= (length (vim.api.nvim_list_tabpages)) 2)})
  (local tabline [bufferline tab-pages])

  (heirline.setup {: statusline : tabline}))

M

