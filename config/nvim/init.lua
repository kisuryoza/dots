local function bootstrap(user, repo)
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/lazy/" .. repo

    if (fn.empty(fn.glob(install_path)) > 0) then
        fn.system({"git", "clone", "--depth", "1", ("https://github.com/" .. user .. "/" .. repo.. ".git"), install_path})
    end
    vim.opt.runtimepath:prepend(install_path)
end

vim.cmd("colorscheme habamax")
bootstrap("folke", "lazy.nvim")
bootstrap("udayvir-singh", "tangerine.nvim")

-- local config = vim.fn.stdpath [[config]]
require "tangerine".setup({
    -- vimrc  = config .. "/init.fnl",
    -- source  = config .. "/fnl",
    target  = vim.fn.stdpath [[cache]] .. "/lua",
    rtpdirs = {"ftplugin"},
    compiler = {
        verbose = false,
        hooks = {"onsave", "oninit"},
    },
    keymaps = {
        eval_buffer = "<Nop>",
        peek_buffer = "<Nop>",
        goto_output = "<Nop>",
    }
})

require("init")
