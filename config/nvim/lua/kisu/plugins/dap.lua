local vk = vim.keymap

local M = {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "rcarriga/nvim-dap-ui",
            version = "4.0.0",
            dependencies = { "nvim-neotest/nvim-nio" },
            config = function()
                local dapui = require("dapui")
                dapui.setup()
                vk.set("n", "<leader>du", dapui.toggle, { desc = "Dap ui toggle" })
            end,
        },
        {
            "theHamsta/nvim-dap-virtual-text",
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
            },
            opts = {
                all_references = true, --[[ text_prefix = " ==> " ]]
            },
        },
    },
    keys = {
        { "<F5>", "<cmd>DapContinue<cr>", desc = "Continue" },
        { "<F10>", "<cmd>DapStepOver<cr>", desc = "Step over" },
        { "<F11>", "<cmd>DapStepInto<cr>", desc = "Step into" },
        { "<F12>", "<cmd>DapStepOut<cr>", desc = "Step out" },
        { "<leader>dt", "<cmd>DapTerminate<cr>", desc = "Terminate" },
        { "<leader>dr", "<cmd>DapToggleRepl<cr>", desc = "Toggle repl" },
        { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint" },
        {
            "<leader>dBb",
            function()
                local dap = require("dap")
                dap.set_breakpoint(nil, nil, vim.fn.input("Log msg: "))
            end,
            desc = "Set breakpoint",
        },
        {
            "<leader>dBs",
            function()
                local dap = require("dap")
                dap.set_breakpoint(
                    vim.fn.input(
                        "Breakpoint condition: ",
                        vim.fn.input("Breakpoint hit condition: "),
                        vim.fn.input("Log msg: ")
                    )
                )
            end,
            desc = "Set breakpoint with conditions",
        },
    },
}

M.config = function()
    local dap, widgets = require("dap"), require("dap.ui.widgets")
    -- local command = require("mason-registry").get_package("codelldb"):get_install_path()
    -- local command = vim.fn.expand("~/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb")
    dap.adapters.lldb = {
        type = "executable",
        -- command = "/usr/bin/codelldb",
        command = "/usr/bin/lldb-dap",
    }
    -- dap.adapters.gdb = {
    --     type = "executable",
    --     command = "gdb",
    --     args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    -- }
    dap.configurations.c = {
        {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
                -- return vim.fn.input("Path to executable: ", (vim.fn.getcwd() .. "/"), "file")
                return coroutine.create(function(coro)
                    local pickers = require("telescope.pickers")
                    local finders = require("telescope.finders")
                    local conf = require("telescope.config").values
                    local actions = require("telescope.actions")
                    local action_state = require("telescope.actions.state")
                    local opts = {}
                    pickers
                        .new(opts, {
                            prompt_title = "Path to executable",
                            finder = finders.new_oneshot_job({ "fd", "--no-ignore" , "--type", "x" }, {}),
                            sorter = conf.generic_sorter(opts),
                            attach_mappings = function(buffer_number)
                                actions.select_default:replace(function()
                                    actions.close(buffer_number)
                                    coroutine.resume(coro, action_state.get_selected_entry()[1])
                                end)
                                return true
                            end,
                        })
                        :find()
                end)
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c
    dap.configurations.zig = dap.configurations.c

    vk.set({ "n", "v" }, "<leader>dwh", widgets.hover, { desc = "Widgets hover" })
    vk.set({ "n", "v" }, "<leader>dwp", widgets.preview, { desc = "Widgets preview" })
    vk.set("n", "<leader>dwf", function() widgets.centered_float(widgets.frames) end, { desc = "Widgets float" })
    vk.set("n", "<leader>dws", function() widgets.centered_float(widgets.scopes) end, { desc = "Widgets scope" })
end

return M
