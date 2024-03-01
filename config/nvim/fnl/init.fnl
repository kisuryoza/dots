(import-macros {: setup!} :macros)

; (fn change-alacritty-font [font]
;   (let [font (if (= nil font)
;                  ;; Get a default font from the config
;                  (let [command "awk -F ': ' '/family/ {print $NF; exit}' ~/.config/alacritty/alacritty.yml"
;                        handle (io.popen command)
;                        result (handle:read :*a)]
;                    (handle:close)
;                    result)
;                  font)
;         str (.. "alacritty msg config font.normal.family='" font
;                 "' font.bold.family='" font "' font.italic.family='" font
;                 "' font.bold_italic.family='" font "'")]
;     (os.execute str)))

; (change-alacritty-font "JetBrains Mono")

;; Change terminal font back on nvim exit
; (vim.api.nvim_create_autocmd :VimLeavePre {:callback #(change-alacritty-font)})

((setup! :lazy) (require :plugins)
                {:lockfile (.. (vim.fn.stdpath :data) :/lazy-lock.json)
                 :performance {:cache {:enabled true}
                               :rtp {:disabled_plugins [:gzip
                                                        :matchit
                                                        :tarPlugin
                                                        :tohtml
                                                        :tutor]}}})

(require :configs.opts)
(require :configs.key_maps)

(vim.api.nvim_create_autocmd :BufWritePre
                             {:pattern ["*"]
                              :desc "Deletes trailing spaces and replaces tabs w/ spaces on save"
                              :callback #(when (not vim.o.binary)
                                           (let [winview vim.fn.winsaveview]
                                             (vim.cmd "keeppatterns %s/\\s\\+$//e")
                                             (vim.cmd :retab)
                                             (vim.fn.winrestview (winview))))})

(vim.api.nvim_create_autocmd [:FocusGained :BufEnter]
                             {:pattern ["*"]
                              :desc "Reload file for changes"
                              :command :checktime})

(vim.api.nvim_create_autocmd :BufWritePre
                             {:pattern :*.rs
                              :desc "Formats rust files before save"
                              :callback #(vim.lsp.buf.format {:timeout_ms 200})})

(vim.api.nvim_create_autocmd :BufReadPost
                             {:pattern "*"
                              :desc "Open file at the last position it was edited earlier"
                              :command "silent! normal! g`\"zv"})
