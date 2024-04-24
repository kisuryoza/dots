(require-macros :macros)

(map! :t :<Esc> (vim.api.nvim_replace_termcodes "<C-\\><C-n>" true true true)
      "Exit terminal mode")

(nmap! :<C-d> :<C-d>zz)
(nmap! :<C-u> :<C-u>zz)
(nmap! :<Esc> (cmd! :noh) "Turn off highlighting")
(nmap! :<C-t> (cmd! :tabnew))
(nmap! :<C-Left> (cmd! :tabprevious))
(nmap! :<C-Right> (cmd! :tabnext))

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

(nmapp! :bd (cmd! "lcd %:p:h") "Set local working dir")
(nmapp! :bD (cmd! "cd %:p:h") "Set global working dir")

(nmapp! :fc (cmd! "e $MYVIMRC | :cd %:p:h") "Edit neovm config")
(nmapp! :fx (cmd! "!chmod +x %") "Make curr file executable")

;; Code related
(nmapp! :ca vim.lsp.buf.code_action "Code actions")
(nmapp! :cf #(vim.lsp.buf.format {:async true}) "Format buffer")

