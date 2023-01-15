(import-macros {: setup!} :macros)

(require :opts)

((setup! :lazy)
 (require :plugins)
 {:lockfile (.. (vim.fn.stdpath :data) :/lazy-lock.json)
  :performance {:cache {:enabled true}
                :rtp {:disabled_plugins [:gzip
                                         :matchit
                                         :netrwPlugin
                                         :tarPlugin
                                         :tohtml
                                         :tutor
                                         :zipPlugin]}}})

(fn FileReformatting []
  (if (not vim.o.binary)
    (let [winview vim.fn.winsaveview]
      (vim.cmd "keeppatterns %s/\\s\\+$//e")
      (vim.cmd "retab")
      (vim.fn.winrestview (winview)))))

;; Deletes trailing spaces and replaces tabs w/ spaces
(vim.api.nvim_create_autocmd
  ["BufWritePre" "FileWritePre" "FileAppendPre" "FilterWritePre"]
  {:pattern ["*"]
   :callback #(FileReformatting)})

;; Reload file for changes
(vim.api.nvim_create_autocmd
  ["FocusGained" "BufEnter"]
  {:pattern ["*"]
   :command "checktime"})

;; Wipes hidden buffers
;; (vim.cmd "autocmd BufReadPost * set bufhidden=wipe")
