(import-macros {: setup!} :macros)

(fn change-alacritty-font [font]
  (let [font (if (= nil font)
                 ;; Get a default font from the config
                 (let [command "awk -F ': ' '/family/ {print $NF; exit}' ~/.config/alacritty/alacritty.yml"
                       handle (io.popen command)
                       result (handle:read :*a)]
                   (handle:close)
                   result)
                 font)
        str (.. "alacritty msg config font.normal.family='" font
                "' font.bold.family='" font "' font.italic.family='" font
                "' font.bold_italic.family='" font "'")]
    (os.execute str)))

(change-alacritty-font "JetBrains Mono")

(require :configs.opts)

((setup! :lazy) (require :plugins)
                {:lockfile (.. (vim.fn.stdpath :data) :/lazy-lock.json)
                 :performance {:cache {:enabled true}
                               :rtp {:disabled_plugins [:gzip
                                                        :matchit
                                                        :netrwPlugin
                                                        :tarPlugin
                                                        :tohtml
                                                        :tutor]}}})

;; Deletes trailing spaces and replaces tabs w/ spaces on save
(vim.api.nvim_create_autocmd :FileWritePre
                             {:pattern ["*"]
                              :callback (fn []
                                          (if (not vim.o.binary)
                                              (let [winview vim.fn.winsaveview]
                                                (vim.cmd "keeppatterns %s/\\s\\+$//e")
                                                (vim.cmd :retab)
                                                (vim.fn.winrestview (winview)))))})

;; Reload file for changes
(vim.api.nvim_create_autocmd [:FocusGained :BufEnter]
                             {:pattern ["*"] :command :checktime})

;; Formats rust files on save
(vim.api.nvim_create_autocmd :BufWritePre
                             {:pattern :*.rs
                              :callback #(vim.lsp.buf.format {:timeout_ms 200})})

;; Change terminal font back on nvim exit
(vim.api.nvim_create_autocmd :VimLeavePre {:callback #(change-alacritty-font)})

;; Wipes hidden buffers
;; (vim.api.nvim_create_autocmd [:BufReadPost]
;;                              {:pattern ["*"]
;;                               :command "set bufhidden=wipe"}))
