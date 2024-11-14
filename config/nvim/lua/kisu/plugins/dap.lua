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
        { "<leader>dt", "<cmd>DapTerminate<cr>", desc = "Terminate" },
        { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue" },
        { "<leader>dr", "<cmd>DapToggleRepl<cr>", desc = "Toggle repl" },
        { "<leader>dn", "<cmd>DapStepOver<cr>", desc = "Step over" },
        { "<leader>di", "<cmd>DapStepInto<cr>", desc = "Step into" },
        { "<leader>df", "<cmd>DapStepOut<cr>", desc = "Step out" },
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
    local command = vim.fn.expand("~/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb")
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = command,
            args = { "--port", "${port}" },
        },
    }
    dap.configurations.c = {
        {
            name = "codelldb",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", (vim.fn.getcwd() .. "/"), "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = {
        {
            name = "codelldb",
            type = "codelldb",
            request = "launch",
            program = function()
                vim.notify("Building...", vim.log.levels.WARN)
                vim.fn.system("cargo build")
                local output = vim.fn.system("cargo metadata --format-version=1 --no-deps")
                local artifact = vim.fn.json_decode(output)
                local target_name = artifact.packages[1].targets[1].name
                local target_dir = artifact.target_directory
                vim.notify(("Binary name: " .. target_name), vim.log.levels.INFO)
                return target_dir .. "/debug/" .. target_name
            end,
        },
    }

    vk.set({ "n", "v" }, "<leader>dwh", widgets.hover, { desc = "Widgets hover" })
    vk.set({ "n", "v" }, "<leader>dwp", widgets.preview, { desc = "Widgets preview" })
    vk.set("n", "<leader>dwf", function()
        widgets.centered_float(widgets.frames)
    end, { desc = "Widgets float" })
    vk.set("n", "<leader>dws", function()
        widgets.centered_float(widgets.scopes)
    end, { desc = "Widgets scope" })
end

return M
