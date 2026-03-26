-- ============================================================================
-- LSP MODULE ORCHESTRATION
-- ============================================================================

-- Load LSP modules in correct order
require("mason").setup({})
require("core.tooling").setup()
require("plugins.lsp.config")
require("plugins.lsp.handlers")
require("plugins.lsp.efm")
require("plugins.lsp.servers")
