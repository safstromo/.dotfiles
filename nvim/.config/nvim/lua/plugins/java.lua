return {
	"nvim-java/nvim-java",
	setup = {
		jdtls = function()
			require("java").setup({
				jdk = {
					auto_install = false,
				},
			})
		end,
	},
}
