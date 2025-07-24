local map = vim.keymap.set

local dap, widgets = require("dap"), require("dap.ui.widgets")
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
                        finder = finders.new_oneshot_job({ "fd", "--no-ignore", "--type", "x" }, {}),
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

map("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "Continue" })
map("n", "<F10>", "<cmd>DapStepOver<cr>", { desc = "Step over" })
map("n", "<F11>", "<cmd>DapStepInto<cr>", { desc = "Step into" })
map("n", "<F12>", "<cmd>DapStepOut<cr>", { desc = "Step out" })
map("n", "<leader>dt", "<cmd>DapTerminate<cr>", { desc = "Terminate" })
map("n", "<leader>dr", "<cmd>DapToggleRepl<cr>", { desc = "Toggle repl" })
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle breakpoint" })
map(
    "n",
    "<leader>dBb",
    function() dap.set_breakpoint(nil, nil, vim.fn.input("Log msg: ")) end,
    { desc = "Set breakpoint" }
)
map(
    "n",
    "<leader>dBs",
    function()
        dap.set_breakpoint(
            vim.fn.input(
                "Breakpoint condition: ",
                vim.fn.input("Breakpoint hit condition: "),
                vim.fn.input("Log msg: ")
            )
        )
    end,
    { desc = "Set breakpoint with conditions" }
)

map({ "n", "v" }, "<leader>dwh", widgets.hover, { desc = "Widgets hover" })
map({ "n", "v" }, "<leader>dwp", widgets.preview, { desc = "Widgets preview" })
map("n", "<leader>dwf", function() widgets.centered_float(widgets.frames) end, { desc = "Widgets float" })
map("n", "<leader>dws", function() widgets.centered_float(widgets.scopes) end, { desc = "Widgets scope" })

local dapui = require("dapui")
dapui.setup()
map("n", "<leader>du", dapui.toggle, { desc = "Dap ui toggle" })
-- require("nvim-dap-virtual-text").setup({ all_references = true })
