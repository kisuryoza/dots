(import-macros {: cmd! : map! : nmap! : vmap! : nmapp!} :macros)

(set vim.g.mapleader " ")
(set vim.g.maplocalleader "\\")

(map! :t :<Esc> (vim.api.nvim_replace_termcodes "<C-\\><C-n>" true true true)
      "Exit terminal mode")

(nmap! :<C-d> :<C-d>zz)
(nmap! :<C-u> :<C-u>zz)
(nmap! :<Esc> (cmd! :noh) "Turn off highlighting")
(nmap! :<C-t> (cmd! :tabnew))
(nmap! :<C-Left> (cmd! :tabprevious))
(nmap! :<C-Right> (cmd! :tabnext))
(nmapp! :<Tab> "<Plug>(leap-forward)" "Leap forward")
(nmapp! :<S-Tab> "<Plug>(leap-backward)" "Leap backward")

(vmap! :y :ygv<esc> "Yank sel text w/out moving cursor back")
(vmap! :J ":m '>+1<CR>gv=gv" "Move selected Down")
(vmap! :K ":m '<-2<CR>gv=gv" "Move selected Up")

(nmapp! :z (cmd! :ZenMode) :ZenMode)

(fn toggle-opt [option on off]
  (var curr_value (: (. vim.opt option) :get))
  (if (= (type curr_value) :table)
      (set curr_value (. curr_value (next curr_value))))
  (if (= curr_value on)
      (tset vim.opt option off)
      (tset vim.opt option on)))

;; Toggle options
(nmapp! :on #(toggle-opt :number true false) :Number)
(nmapp! :or #(toggle-opt :relativenumber true false) "Relative number")
(nmapp! :ov #(toggle-opt :virtualedit :all :block) "Virtual edit")
(nmapp! :oi #(toggle-opt :list true false) "Show invisible")
(nmapp! :os #(toggle-opt :spell true false) :Spell)
(nmapp! :ow #(toggle-opt :wrap true false) :Wrap)
(nmapp! :oc #(toggle-opt :colorcolumn :80 :0) "Color column")
(nmapp! :ol #(toggle-opt :cursorline true false) "Cursor line")

;; Diagnostic, QuickFixList, LocList
(nmapp! :e vim.diagnostic.open_float "Diagnostic menu")
(nmap! "[d" vim.diagnostic.goto_prev "Goto prev diag message")
(nmap! "]d" vim.diagnostic.goto_next "Goto next diag message")
(nmapp! :bq vim.diagnostic.setqflist "Add all diags to qflist")
(nmap! "[q" :<cmd>cprev<CR>zz "qflist prev")
(nmap! "]q" :<cmd>cnext<CR>zz "qflist next")
(nmapp! :bl vim.diagnostic.setloclist "Add buf diags to loclist")
(nmap! "[l" :<cmd>lprev<CR>zz "loclist prev")
(nmap! "]l" :<cmd>lnext<CR>zz "loclist next")

;; Buffers managment
(nmapp! :bd (cmd! "lcd %:p:h") "Set local working dir")
(nmapp! :bD (cmd! "cd %:p:h") "Set global working dir")

;; Files managment
(nmapp! :fc (cmd! "e $MYVIMRC | :cd %:p:h") "Edit neovm config")

(let [builtin (require :telescope.builtin)]
  (nmapp! :bb #(builtin.buffers) :Buffers)
  (nmapp! :ff #(builtin.find_files) "Find Files")
  (nmapp! :fr #(builtin.oldfiles) :Recent)
  (nmapp! :fl #(builtin.live_grep) "Live grep")
  (nmapp! :fg #(let [word (vim.fn.input "Grep > ")]
                 (builtin.grep_string {:search word}))
          "Grep word")
  (nmapp! :fw #(let [word (vim.fn.expand :<cword>)]
                 (builtin.grep_string {:search word}))
          "Grep curr word")
  (nmapp! :fW #(let [word (vim.fn.expand :<cWORD>)]
                 (builtin.grep_string {:search word}))
          "Grep curr WORD"))

(nmapp! :fx (cmd! "!chmod +x %") "Make curr file executable")

;; Code related
(nmapp! :ca vim.lsp.buf.code_action "Code actions")
(nmapp! :cf #(vim.lsp.buf.format {:async true}) "Format buffer")
; (nmapp! :cx (cmd! :TroubleToggle) "List of errors")
(nmapp! :ct (cmd! :TodoQuickFix) "List of TODOs")
(nmapp! :cu #((. (require :undotree) :toggle)) :Undotree)

;; Git
(nmapp! :gn (cmd! :Neogit) "Open Neogit")
(nmapp! :gl (cmd! "Gitsigns toggle_linehl") "Highlight lines")
(nmapp! :gb (cmd! "Gitsigns toggle_current_line_blame") "Toggle line blame")
(nmapp! :ghr (cmd! "Gitsigns reset_hunk") "Reset hunk")
(nmapp! :ghP (cmd! "Gitsigns preview_hunk_inline") "Preview hunk")
(nmapp! :ghp (cmd! "Gitsigns prev_hunk") "Prev hunk")
(nmapp! :ghn (cmd! "Gitsigns next_hunk") "Next hunk")
(nmapp! :ghs (cmd! "Gitsigns select_hunk") "Select hunk")

(let [harpoon (require :harpoon)]
  (nmapp! :a #(: (harpoon:list) :append) "Add file to Harpoon")
  (nmapp! :H #(harpoon.ui:toggle_quick_menu (harpoon:list)) "Harpoon open")
  (nmap! :<C-k> #(: (harpoon:list) :prev) "Harpoon prev")
  (nmap! :<C-j> #(: (harpoon:list) :next) "Harpoon next")
  (nmapp! :ht (cmd! "Telescope harpoon marks") "Harpoon telescope")
  (nmapp! :hq #(: (harpoon:list) :select 1) "Navig 1")
  (nmapp! :hw #(: (harpoon:list) :select 2) "Navig 2")
  (nmapp! :he #(: (harpoon:list) :select 3) "Navig 3")
  (nmapp! :hr #(: (harpoon:list) :select 4) "Navig 4"))

(fn crates-mapping [args]
  (let [buff args.buf
        crates (require :crates)]
    (nmapp! :Cp crates.show_popup "Crates: Show popup" buff)
    (nmapp! :Cf crates.show_features_popup "Crates: Features" buff)
    (nmapp! :Cd crates.show_dependencies_popup "Crates: Dependencies" buff)))

(vim.api.nvim_create_autocmd :BufEnter
                             {:pattern :Cargo.toml
                              :callback (fn [args] (crates-mapping args))})

; (let [ufo (require :ufo)]
;   (nmap! :zR #(ufo.openAllFolds) :openAllFolds)
;   (nmap! :zM #(ufo.closeAllFolds) :closeAllFolds)
;   (nmap! :zr #(ufo.openFoldsExceptKinds) :openFoldsExceptKinds)
;   (nmap! :zm #(ufo.closeFoldsWith 3) :closeFoldsWith))

