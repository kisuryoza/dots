(import-macros {: setup!} :macros)

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

(let [group (vim.api.nvim_create_augroup :UserGrp {})]
  ;; Deletes trailing spaces and replaces tabs w/ spaces on save
  (vim.api.nvim_create_autocmd [:BufWritePre
                                :FileWritePre
                                :FileAppendPre
                                :FilterWritePre]
                               {:pattern ["*"]
                                :callback (fn []
                                            (if (not vim.o.binary)
                                                (let [winview vim.fn.winsaveview]
                                                  (vim.cmd "keeppatterns %s/\\s\\+$//e")
                                                  (vim.cmd :retab)
                                                  (vim.fn.winrestview (winview)))))
                                : group})
  ;; Reload file for changes
  (vim.api.nvim_create_autocmd [:FocusGained :BufEnter]
                               {:pattern ["*"] :command :checktime : group}))
  ;; Wipes hidden buffers
  ;; (vim.api.nvim_create_autocmd [:BufReadPost]
  ;;                              {:pattern ["*"]
  ;;                               :command "set bufhidden=wipe"
  ;;                               : group}))
