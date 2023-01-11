(import-macros {: pack
                : setup!} :macros)

(local M
  (pack :nvim-orgmode/orgmode {:dependencies [(pack :lukas-reineke/headlines.nvim {:config #((setup! :headlines) {:org {:fat_headlines false}})})
                                              (pack :akinsho/org-bullets.nvim {:config #((setup! :org-bullets))})]}))

(fn M.config []
  (local orgmode (require :orgmode))

  (orgmode.setup_ts_grammar)

  (orgmode.setup {})

  (fn file-tangle []
    (local buffer (vim.api.nvim_buf_get_lines 0 0 (- 1) false))
    (var begin false)
    (var tangle true)
    (var tangle-file "")
    (var params {})

    ;; searches for general properties
    (each [_ i (ipairs buffer)]
      (when (string.find i "%#%+PROPERTY")
        (each [j (string.gmatch i "%S+")]
          (table.insert params j))
        (for [j 1 (length params)]
          (when (= (. params j) ":tangle")
            (set tangle-file (. params (+ j 1)))
            (lua :break)))
        (lua :break)))

    (if (not= tangle-file "")
      (let [openedfile (vim.api.nvim_buf_get_name 0)
            file (io.open (.. (string.match openedfile "^.*/") tangle-file) :w)]

        ;; iterates through each line and writes blocks into the file
        (each [_ i (ipairs buffer)]
          (when (string.find (string.upper i) "%#%+END_SRC")
            (set begin false)
            (when (= tangle true)
              (file:write "\n")))
          (when (= begin true)
            (file:write i)
            (file:write "\n"))
          (when (string.find (string.upper i) "%#%+BEGIN_SRC")
            (set begin true)
            (set tangle true)
            (when (string.find i ":tangle no")
              (set tangle false)
              (set begin false))))
        (file:close))))

  (vim.api.nvim_create_autocmd ["BufWritePost"]
                               {:pattern ["*.org"]
                                :callback #(file-tangle)}))

M
