(import-macros {: pack : get_hl_fg! : get_hl_bg!} :macros)

(local M (pack :rebelot/heirline.nvim))

(fn M.config []
  (local heirline (require :heirline))
  (local conditions (require :heirline.conditions))
  (local utils (require :heirline.utils))
  (local devicons (require :nvim-web-devicons))
  (local diag vim.diagnostic)
  (local colors {:bg_dim (get_hl_bg! :NormalNC)
                 :bright_bg (get_hl_bg! :Folded)
                 :blue (get_hl_fg! :Function)
                 :bright_fg (get_hl_fg! :Folded)
                 :cyan (get_hl_fg! :Special)
                 :dark_red (get_hl_fg! :DiffDelete)
                 :diag_error (get_hl_fg! :DiagnosticError)
                 :diag_hint (get_hl_fg! :DiagnosticHint)
                 :diag_info (get_hl_fg! :DiagnosticInfo)
                 :diag_warn (get_hl_fg! :DiagnosticWarn)
                 :git_add (get_hl_fg! :diffAdded)
                 :git_change (get_hl_fg! :diffChanged)
                 :git_del (get_hl_fg! :diffRemoved)
                 :gray (get_hl_fg! :NonText)
                 :green (get_hl_fg! :String)
                 :orange (get_hl_fg! :Constant)
                 :purple (get_hl_fg! :Statement)
                 :red (get_hl_fg! :DiagnosticError)
                 :type (get_hl_fg! :Type)
                 :TabLineSel (get_hl_fg! :TabLineSel)})
  (local align {:provider "%="})
  (local space {:provider " "})
  (local vim-mode {:init (fn [self]
                           (set self.mode (vim.fn.mode 1)))
                   ;; https://neovim.io/doc/user/builtin.html#mode()
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
                   :hl (fn [self]
                         (let [bg (or (?. self.modes self.mode 2) :gray)]
                           {:bold true : bg}))
                   :provider (fn [self]
                               (.. " "
                                   (or (?. self.modes self.mode 1) self.mode)
                                   " "))})
  (local git {:condition conditions.is_git_repo
              :init (fn [self]
                      (set self.status_dict vim.b.gitsigns_status_dict)
                      (set self.has_changes
                           (or (or (not= self.status_dict.added 0)
                                   (not= self.status_dict.removed 0))
                               (not= self.status_dict.changed 0))))
              :hl {:bg colors.bg_dim}
              :flexible 2
              1 [{:provider (fn [self] (.. " 󰘬 " self.status_dict.head " "))
                  :hl {:bg colors.orange}}
                 {:condition (fn [self] self.has_changes) 1 space}
                 {:provider (fn [self]
                              (local count (or self.status_dict.added 0))
                              (and (> count 0) (.. "+" count)))
                  :hl {:fg colors.git_add}}
                 {:provider (fn [self]
                              (local count (or self.status_dict.removed 0))
                              (and (> count 0) (.. "-" count)))
                  :hl {:fg colors.git_del}}
                 {:provider (fn [self]
                              (local count (or self.status_dict.changed 0))
                              (and (> count 0) (.. "~" count)))
                  :hl {:fg colors.git_change}}]
              2 {:provider ""}})
  ;; this is the parent for the file's block
  (local file {:init (fn [self]
                       (let [file (vim.api.nvim_buf_get_name 0)]
                         (set self.file file)))
               :hl {:fg colors.type :bg colors.bg_dim}})
  ;; provides file's icon
  (local file-icon
         {:init (fn [self]
                  (let [file self.file
                        extension (vim.fn.fnamemodify file ":e")]
                    (set (self.icon self.icon_color)
                         (devicons.get_icon_color file extension
                                                  {:default true}))))
          :hl (fn [self] {:fg self.icon_color})
          :provider (fn [self]
                      (and self.icon (.. self.icon " ")))})
  ;; provides file's name
  (local file-name {:provider (fn [self]
                                (let [path (vim.fn.fnamemodify self.file ":.")]
                                  (if (not= path "")
                                      (.. (if (conditions.width_percent_below (length path)
                                                                              0.25)
                                              path
                                              (vim.fn.pathshorten path 5))
                                          " ")
                                      "[No Name]")))})
  ;; provides file's status
  (local file-flags [{:condition (fn [self]
                                   (let [bufnr (or self.bufnr 0)]
                                     (vim.api.nvim_buf_get_option bufnr
                                                                  :modified)))
                      :hl {:fg colors.green}
                      :provider "● "}
                     {:condition (fn [self]
                                   (let [bufnr (or self.bufnr 0)]
                                     (not (vim.api.nvim_buf_get_option bufnr
                                                                       :modifiable))))
                      :hl {:fg colors.orange}
                      :provider " "}
                     {:condition (fn [self]
                                   (let [bufnr (or self.bufnr 0)]
                                     (= (vim.api.nvim_buf_get_option bufnr
                                                                     :buftype)
                                        :terminal)))
                      :hl {:fg colors.orange}
                      :provider " "}])
  (local file (utils.insert file space file-icon file-name file-flags))

  (fn diag-count [severity bufnr icon]
    (let [count (vim.tbl_count (diag.get bufnr {: severity}))]
      (when (and count (> count 0))
        (.. icon " " count))))

  (local lsp-CodeAction
         [{:hl {:fg colors.diag_error}
           :provider (fn []
                       (if vim.g.myvarLspCodeAction "💡" ""))}])
  (local lsp-status
         [{:hl {:fg colors.diag_error}
           :provider (fn [self]
                       (let [bufnr (or self.bufnr 0)]
                         (diag-count diag.severity.ERROR bufnr "")))}
          {:hl {:fg colors.diag_warn}
           :provider (fn [self]
                       (let [bufnr (or self.bufnr 0)]
                         (diag-count diag.severity.WARN bufnr "")))}
          {:hl {:fg colors.diag_info}
           :provider (fn [self]
                       (let [bufnr (or self.bufnr 0)]
                         (diag-count diag.severity.INFO bufnr "")))}
          {:hl {:fg colors.diag_hint}
           :provider (fn [self]
                       (let [bufnr (or self.bufnr 0)]
                         (diag-count diag.severity.HINT bufnr "")))}
          space])
  (local file-encoding
         {:hl {:bg colors.cyan}
          :provider (fn []
                      (let [label vim.bo.fileencoding]
                        (and (not= label :utf-8) (label:upper))))})
  (local file-format
         {:hl {:bg colors.cyan}
          :provider (fn []
                      (let [label vim.bo.fileformat]
                        (and (not= label :unix) (label:upper))))})
  (local ruler {:init (fn [self]
                        (let [[line col] (vim.api.nvim_win_get_cursor 0)
                              lines (vim.api.nvim_buf_line_count 0)
                              progress (if (= line 1)
                                           :Top
                                           (= line lines)
                                           :Btm
                                           (.. (math.ceil (* 100 (/ line lines)))
                                               "%%"))]
                          (set self.line line)
                          (set self.col col)
                          (set self.lines lines)
                          (set self.progress progress)))
                :hl {:bg colors.blue}
                :update [:CursorMoved :CursorMovedI]
                :flexible 1
                1 [space
                   [{:provider (fn [self] self.line)}
                    {:provider "/"}
                    {:provider (fn [self] self.lines)}
                    {:provider ":"}
                    {:provider (fn [self] self.col)}]
                   space
                   {:provider (fn [self] self.progress)}
                   space]
                2 {:provider ""}})
  (local file-type
         {:hl {:bg colors.cyan}
          :provider (fn []
                      (let [label vim.bo.filetype]
                        (.. " " (label:upper) " ")))})
  (local no-statusline {:condition (fn []
                                     (conditions.buffer_matches {:buftype [:nofile
                                                                           :prompt
                                                                           :help
                                                                           :quickfix]
                                                                 :filetype [:^git.*
                                                                            :fugitive
                                                                            :alpha]}))
                        1 align})
  (local inactive-statusline
         {:condition conditions.is_not_active :hl {:bg colors.bg_dim}})
  (local inactive-statusline
         (utils.insert inactive-statusline git file align lsp-status file-encoding
                       file-format file-type))
  (local active-statusline [vim-mode
                            git
                            file
                            lsp-CodeAction
                            align
                            lsp-status
                            file-encoding
                            file-format
                            ruler
                            file-type])
  (local statusline {:hl {:fg :black} :fallthrough false})
  (local statusline (utils.insert statusline no-statusline inactive-statusline
                                  active-statusline))
  ;; Tabline
  ;; provides buffer's number
  (local tabline-bfnr {:hl :Comment :provider (fn [self] (.. self.bufnr "."))})
  ;; provides file's name
  (local tabline-file-name
         {:hl (fn [self]
                {:bold self.is_active :italic self.is_visible})
          :provider (fn [self]
                      (let [file self.file]
                        (.. (if (= file "") "[No Name]"
                              (vim.fn.fnamemodify file ":t"))
                            " ")))})
  ;; this is the parent for tabs
  (local bufferline
         {:init (fn [self]
                  (set self.file (vim.api.nvim_buf_get_name self.bufnr)))
          :hl (fn [self] (if self.is_active :TabLineSel :TabLine))
          :on_click {:callback (fn [_ minwid _ button]
                                 (if (= button :r)
                                     (vim.api.nvim_buf_delete minwid
                                                              {:force false})
                                     (vim.api.nvim_win_set_buf 0 minwid)))
                     :minwid (fn [self] self.bufnr)
                     :name :heirline_tabline_buffer_callback}})
  (local bufferline
         (utils.insert bufferline space tabline-bfnr file-icon
                       tabline-file-name file-flags lsp-status))
  ;; (local tabline-buffer-block
  ;;        (utils.surround ["┃" "┃"]
  ;;                        (fn [self]
  ;;                          (if self.is_active
  ;;                              (. (utils.get_highlight :TabLineSel) :bg)
  ;;                              (. (utils.get_highlight :TabLine) :bg)))
  ;;                        [tabline-file-name-block]))
  (local bufferline
         (utils.make_buflist bufferline {:hl {:fg :gray} :provider ""}
                             {:hl {:fg :gray} :provider ""}))
  ;; provides list of tabs
  (local tabpage
         {:hl (fn [self] (if self.is_active :TabLineSel :TabLine))
          :provider (fn [self] (.. "%" self.tabnr "T " self.tabpage " %T"))})
  ;; provides an icon to close current tab
  (local tabpage-close {:hl :TabLine :provider "%999X  %X"})
  (local tab-pages
         {1 align
          2 (utils.make_tablist tabpage)
          3 tabpage-close
          :condition #(>= (length (vim.api.nvim_list_tabpages)) 2)})
  (local tabline [bufferline tab-pages])
  (heirline.setup {: statusline : tabline}))

M

