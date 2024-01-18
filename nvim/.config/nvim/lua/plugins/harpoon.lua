return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({})

            vim.keymap.set("n", "<leader>a", function()
                harpoon:list():append()
            end, { desc = "󱡁 Harpoon Add file" })

            vim.keymap.set("n", "<C-e>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = "󱠿 Harpoon Menu" })

            vim.keymap.set("n", "<leader>j", function()
                harpoon:list():select(1)
            end, { desc = "󱪼 Navigate to file 1" })

            vim.keymap.set("n", "<leader>l", function()
                harpoon:list():select(2)
            end, { desc = "󱪽 Navigate to file 2" })

            vim.keymap.set("n", "<leader>u", function()
                harpoon:list():select(3)
            end, { desc = "󱪾  Navigate to file 3" })

            vim.keymap.set("n", "<leader>y", function()
                harpoon:list():select(4)
            end, { desc = "󱪿  Navigate to file 4" })
        end,
    },
}
