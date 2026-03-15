-- ============================================================================
-- NEOVIM CONFIGURATION - MODULAR STRUCTURE
-- ============================================================================

-- Ensure packer compatibility (vim.pack requires Neovim 0.12+)
if vim.fn.has("nvim-0.12") ~= 1 then
  vim.notify("Neovim 0.12+ required", vim.log.levels.ERROR)
  return
end

-- Load order is critical!
require("core.transparency")        -- 1. UI transparency (no dependencies)
require("core.options")             -- 2. Editor options (no dependencies)
require("ui.statusline")            -- 3. Statusline (needs options, exports globals)
require("core.keymaps")             -- 4. Keymaps (non-plugin only)
require("core.autocommands")        -- 5. Autocmds (creates augroup)
require("plugins")                  -- 6. Load plugins (vim.pack.add + packadd)
require("plugins.terminal")         -- 7. Terminal (creates terminal_state)
require("plugins.claude")           -- 8. Claude (uses terminal_state)
