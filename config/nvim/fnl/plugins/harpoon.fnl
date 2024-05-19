(require-macros :macros)

(local M (pack :ThePrimeagen/harpoon
               {:dependencies [:nvim-lua/plenary.nvim]
                :branch :harpoon2}))
                ; :event :VeryLazy}))

(fn M.config []
  (local harpoon (require :harpoon))
  (local telescope (require :telescope))
  (telescope.load_extension :harpoon)
  (harpoon:setup)
  (nmapp! :a #(: (harpoon:list) :add) "Add file to Harpoon")
  (nmapp! :H #(harpoon.ui:toggle_quick_menu (harpoon:list)) "Harpoon open")
  (nmap! :<C-k> #(: (harpoon:list) :prev) "Harpoon prev")
  (nmap! :<C-j> #(: (harpoon:list) :next) "Harpoon next")
  (nmapp! :ht (cmd! "Telescope harpoon marks") "Harpoon telescope")
  (nmapp! :hq #(: (harpoon:list) :select 1) "Navig 1")
  (nmapp! :hw #(: (harpoon:list) :select 2) "Navig 2")
  (nmapp! :he #(: (harpoon:list) :select 3) "Navig 3")
  (nmapp! :hr #(: (harpoon:list) :select 4) "Navig 4"))

M

