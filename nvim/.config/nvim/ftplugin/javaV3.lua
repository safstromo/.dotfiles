local ok, jdtls = pcall(require, "jdtls")
if not ok then
	vim.notify("jdtls could not be loaded")
	return
end

local ok_mason, mason_registry = pcall(require, "mason-registry")
if not ok_mason then
	vim.notify("mason-registry could not be loaded")
	return
end

local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()

local operative_system
if vim.fn.has("linux") then
	operative_system = "linux"
elseif vim.fn.has("win32") then
	operative_system = "win"
elseif vim.fn.has("macunix") then
	operative_system = "mac"
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.loop.os_homedir() .. "/.cache/jdtls/workspace/" .. project_name

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local jt_path = mason_registry.get_package("java-test"):get_install_path()
local jda_path = mason_registry.get_package("java-debug-adapter"):get_install_path()

local bundles = {}

local jt_server_jars = vim.fn.glob(jt_path .. "/extension/server/*.jar")
vim.list_extend(bundles, vim.split(jt_server_jars, "\n"))

local jda_server_jar = vim.fn.glob(jda_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
vim.list_extend(bundles, vim.split(jda_server_jar, "\n"))

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {
		-- 💀
		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- depends on if `java` is in your $PATH env variable and if it points to the right version.

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. jdtls_path .. "/lombok.jar",

		-- 💀
		"-jar",
		vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
		--          ^^^^^^^^^^                                           ^
		--          Must point to the                                    Change this to
		--          eclipse.jdt.ls                                       the actual version,
		--          installation                                         with vim.fn.glob() is not necessary

		-- 💀
		"-configuration",
		jdtls_path .. "/config_" .. "linux",
		-- ^^^^^^^                  ^^^^^^^^^^^^^^^^
		-- Must point to the        Change to one of `linux`, `win` or `mac`
		-- eclipse.jdt.ls           Depending on your system.
		-- installation

		-- 💀
		-- See `data directory configuration` section in the README
		"-data",
		workspace_dir,
	},

	-- on_attach = require("birdee.lsp.birdeelspconfigs").on_attach,
	-- capabilities = require("birdee.lsp.birdeelspconfigs").get_capabilities(),
	--
	-- 💀
	-- This is the default if not provided, you can remove it. Or adjust as needed.
	-- One dedicated LSP server & client will be started per unique root_dir
	root_dir = require("jdtls.setup").find_root({
		"build.xml",
		"pom.xml",
		"settings.gradle",
		"settings.gradle.kts",
	}),

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					-- {
					-- 	name = "JavaSE-17",
					-- 	path = vim.fn.expand("~/.sdkman/candidates/java/17.0.8-amzn"),
					-- },
					{
						name = "JavaSE-17",
						path = vim.fn.expand("~/.sdkman/candidates/java/21-tem"),
					},
				},
			},
			eclipse = {
				downloadSources = true,
			},
			format = {
				enabled = true,
			},
			implementationsCodeLens = { enabled = true },
			inlayHints = {
				parameterNames = {
					enabled = "all", -- literals, all, none
				},
			},
			maven = {
				downloadSources = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
		},
		redhat = {
			telemetry = { enabled = false },
		},
		signatureHelp = { enabled = true },
		extendedClientCapabilities = extendedClientCapabilities,
	},
	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		-- workspace = workspace_dir,
		bundles = bundles,
	},
}
jdtls.start_or_attach(config)

require("jdtls").setup_dap()

-- Add mappings
local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local vopts = {
	mode = "v", -- VISUAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
	L = {
		name = "Java",
		a = { "<CMD>lua vim.lsp.buf.code_action()<CR>", "See available code actions" },
		o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
		v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
		c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
		t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
		T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
		u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
	},
}

local vmappings = {
	L = {
		name = "Java",
		v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
		c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
		m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
	},
}
which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
