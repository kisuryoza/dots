(import-macros {: pack} :macros)

(local M
  (pack :kyazdani42/nvim-tree.lua {:ft ["alpha"]
                                   :cmd "NvimTreeToggle"}))

(fn M.config []
  (local tree (require :nvim-tree))

  (tree.setup
    {:disable_netrw true
     :hijack_cursor true
     :view {:mappings {:list [{:key "l" :action "edit"}]}}
     :renderer {:add_trailing false
                :group_empty false
                :highlight_git false
                :full_name false
                :highlight_opened_files "all"
                :root_folder_modifier ":~"
                :indent_width 2
                :indent_markers {:enable true
                                 :inline_arrows true
                                 :icons {:corner "└"
                                         :edge "│"
                                         :item "│"
                                         :bottom "─"
                                         :none " "}}
                :icons {:webdev_colors true
                        :git_placement :before
                        :padding " "
                        :symlink_arrow " 󱦰 "
                        :show {:file true
                               :folder true
                               :folder_arrow false
                               :git true}
                        :glyphs {:default "󰈙"
                                 :symlink "󰪹"
                                 :bookmark "󰃀"
                                 :folder {:arrow_closed "󰍴"
                                          :arrow_open "󰐕"
                                          :default "󰉋"
                                          :open "󰝰"
                                          :empty "󰉖"
                                          :empty_open "󰷏"
                                          :symlink "󱧮"
                                          :symlink_open "󱧮"}
                                 :git {:unstaged "󰖭"
                                       :staged "󰄬"
                                       :unmerged "󰘭"
                                       :renamed "󱦰"
                                       :untracked "★"
                                       :deleted ""
                                       :ignored "◌"}}}}
     :actions {:use_system_clipboard true
               :change_dir {:enable true
                            :global true
                            :restrict_above_cwd false}
               :open_file {:quit_on_open true}}}))

M
