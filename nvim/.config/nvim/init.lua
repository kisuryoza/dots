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
bootstrap("rktjmp", "hotpot.nvim")

if pcall(require, "hotpot") then
    require("hotpot").setup({
        provide_require_fennel = false,
        enable_hotpot_diagnostics = true,
    })

    require("init")
end
