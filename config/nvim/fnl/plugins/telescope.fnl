(require-macros :macros)

(local M (pack :nvim-telescope/telescope.nvim
               {:dependencies [:nvim-lua/plenary.nvim
                               :nvim-tree/nvim-web-devicons
                               :nvim-telescope/telescope-fzy-native.nvim
                               :nvim-telescope/telescope-ui-select.nvim]
                :event :VeryLazy}))

(fn M.config []
  (local telescope (require :telescope))
  (telescope.setup {:extensions {:fzy_native {:override_generic_sorter false
                                              :override_file_sorter true}}})
  (telescope.load_extension :fzy_native)
  (telescope.load_extension :harpoon)
  (telescope.load_extension :ui-select)
  ; (local trouble (require :trouble.providers.telescope))
  ; (telescope.setup {:defaults {:mappings {:i {:<c-t> trouble.open_with_trouble}
  ;                                         :n {:<c-t> trouble.open_with_trouble}}}})
  (let [builtin (require :telescope.builtin)]
    (nmapp! :bb builtin.buffers :Buffers)
    (nmapp! :ff builtin.find_files "Find Files")
    (nmapp! :fr builtin.oldfiles :Recent)
    (nmapp! :fl builtin.live_grep "Live grep")
    (nmapp! :fg #(let [word (vim.fn.input "Grep > ")]
                   (builtin.grep_string {:search word}))
            "Grep word")
    (nmapp! :fw #(let [word (vim.fn.expand :<cword>)]
                   (builtin.grep_string {:search word}))
            "Grep curr word")
    (nmapp! :fW #(let [word (vim.fn.expand :<cWORD>)]
                   (builtin.grep_string {:search word}))
            "Grep curr WORD")))

M

