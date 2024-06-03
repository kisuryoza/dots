local vk = vim.keymap

local M = {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "rcarriga/nvim-dap-ui",
            version = "4.0.0",
            dependencies = "nvim-neotest/nvim-nio",
            config = function()
                local dapui = require("dapui")
                dapui.setup()
                vk.set("n", "<leader>du", dapui.toggle, { desc = "Dap ui toggle" })
            end,
        },
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {
                all_references = true, --[[ text_prefix = " ==> " ]]
            },
        },
    },
    ft = { "c", "cpp", "rust" },
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
    vk.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
    vk.set("n", "<leader>dc", dap.continue, { desc = "Continue" })

    vk.set("n", "<leader>dr", dap.repl.open, { desc = "Repl open" })
    vk.set("n", "<leader>ddl", dap.run_last, { desc = "Run last" })

    vk.set("n", "<leader>dso", dap.step_over, { desc = "Step over" })
    vk.set("n", "<leader>dsi", dap.step_into, { desc = "Step into" })
    vk.set("n", "<leader>dsO", dap.step_out, { desc = "Step out" })

    vk.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vk.set("n", "<leader>dBb", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log msg: "))
    end, { desc = "Set breakpoint" })
    vk.set("n", "<leader>dBs", function()
        dap.set_breakpoint(
            vim.fn.input(
                "Breakpoint condition: ",
                vim.fn.input("Breakpoint hit condition: "),
                vim.fn.input("Log msg: ")
            )
        )
    end, { desc = "Set breakpoint with conditions" })

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
