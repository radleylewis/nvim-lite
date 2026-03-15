<!--
Sync Impact Report:
- Version change: Initial → 1.0.0
- Modified principles: N/A (initial version)
- Added sections: Core Principles (5 principles), Technology Constraints, Development Workflow, Governance
- Removed sections: N/A (initial version)
- Templates status:
  ✅ specs/templates/plan-template.md - Created
  ✅ specs/templates/spec-template.md - Created
  ✅ specs/templates/spec-checklist.md - Created
  ✅ specs/templates/tasks-template.md - Created
- Follow-up TODOs: None
-->

# nvim-lite Constitution

## Core Principles

### I. Minimalism First

The configuration MUST prioritize simplicity and maintainability over abstraction layers:

- **Single-file preference**: When practical, keep related configuration together in `init.lua`
- **No premature modularity**: Only split into modules when files exceed 300 lines or when clear separation of concerns emerges
- **YAGNI enforcement**: Do not add features "for someday" - every line must justify its existence
- **Documentation over complexity**: Prefer clear comments and self-documenting code over complex abstractions

**Rationale**: A minimal configuration is easier to understand, debug, and maintain. Each abstraction layer adds cognitive overhead and potential failure points.

### II. Native APIs (NON-NEGOTIABLE)

Prefer NeoVim's built-in capabilities over external solutions:

- **Plugin management**: MUST use `vim.pack.add()` (NeoVim 0.12+ native), NOT external plugin managers
- **LSP configuration**: MUST use `vim.lsp.config()` (NeoVim 0.12+ API), NOT `nvim-lspconfig` legacy setup
- **Tree-sitter**: Use built-in treesitter integration, avoid unnecessary wrapper plugins
- **External dependencies**: Each external plugin MUST solve a problem that cannot be addressed with built-in features

**Rationale**: Native APIs are more stable, better maintained, and reduce dependency surface area. External plugin managers and configuration layers introduce unnecessary complexity.

### III. Modern Standards

Target current NeoVim versions and embrace modern APIs:

- **Minimum version**: NeoVim 0.12+ (leverage latest APIs, deprecate old patterns)
- **Lua over Vimscript**: All new configurations MUST be in Lua
- **Feature detection**: Use `has()` and version checks to gracefully handle version differences
- **Deprecation monitoring**: Review NeoVim release notes quarterly; remove deprecated APIs

**Rationale**: Modern APIs provide better functionality, performance, and maintainability. Holding onto old patterns prevents leveraging improvements.

### IV. Developer Experience

Configuration MUST enhance productivity, not just configure the editor:

- **Format on save**: Automatic formatting for all supported filetypes when efm-langserver is attached
- **LSP first-class**: Language server integration for navigation, hover, completion, code actions
- **Fuzzy finding**: Integration with fzf/ripgrep/fd for fast file/content search
- **Claude Code integration**: Seamless terminal-based AI assistant workflow
- **Ergonomic keybindings**: Leader key consistency, window navigation without prefix (Ctrl+h/j/k/l)

**Rationale**: The configuration exists to make development more efficient. Every feature should contribute to that goal.

### V. Testability & Debuggability

Configuration MUST be verifiable and issues must be diagnosable:

- **Plugin lock file**: `nvim-pack-lock.json` MUST be committed for reproducibility
- **Health checks**: Configuration should not prevent NeoVim from starting if a plugin fails
- **Error visibility**: LSP diagnostics, format errors, and plugin issues MUST be visible to users
- **Runtime guidance**: CLAUDE.md MUST accurately reflect current configuration behavior
- **Minimal magic**: Avoid clever code that's hard to debug; explicit is better than implicit

**Rationale**: When configuration breaks, users need to understand why. Reproducible installs and clear error messages are essential.

## Technology Constraints

### Allowed Dependencies

- **Required**: NeoVim 0.12+, tree-sitter-cli 0.26.5+, golang (for efm-langserver), lua-jsregexp
- **Recommended**: fzf, ripgrep, fd
- **Prohibited**: External plugin managers (vim-plug, packer, lazy.nvim, etc.)
- **Plugin additions**: MUST justify why built-in features are insufficient

### Plugin Selection Criteria

Before adding a plugin, ALL of the following MUST be true:

1. Problem cannot be solved with NeoVim built-in features
2. Plugin is actively maintained (last commit within 6 months)
3. Plugin does not duplicate functionality of existing plugins
4. Plugin configuration fits within ~50 lines (excluding snippet definitions)
5. Plugin does NOT introduce its own dependency management system

### File Organization

- **Primary configuration**: `init.lua` (all core settings)
- **Plugin lock file**: `nvim-pack-lock.json` (git tracked, auto-generated)
- **Language server config**: `.luarc.json` (declares vim global for Lua LSP)
- **Documentation**: CLAUDE.md (project instructions for Claude Code)

Modularization is permitted only when:
- A single section exceeds 300 lines, OR
- Clear separation of concerns emerges (e.g., LSP configs, plugin specs)
- Module name and purpose are self-explanatory

## Development Workflow

### Configuration Changes

1. **Edit directly**: Modify `init.lua` (or module files if modularized)
2. **Test locally**: Restart NeoVim to verify changes work as expected
3. **Update documentation**: Keep CLAUDE.md in sync with actual behavior
4. **Commit**: Use conventional commit messages (feat:, fix:, refactor:, docs:)

### Plugin Management

- **Adding plugins**: Add `vim.pack.add()` call in plugins section
- **Updating plugins**: Restart NeoVim; plugins update automatically, lock file tracks revisions
- **Removing plugins**: Remove `vim.pack.add()` call, delete plugin references, restart NeoVim
- **Lock file**: Commit `nvim-pack-lock.json` after plugin changes

### Code Quality

- **Lua linting**: Configure Lua LSP to catch syntax and type errors
- **Self-review**: Before committing, test that NeoVim starts without errors
- **Documentation**: Update CLAUDE.md when adding new keybindings or features

### Git Workflow

- **Branch strategy**: Feature branches for significant changes
- **Commit messages**: Conventional commits with clear descriptions
- **Pull requests**: Required for merging to master
- **Tags**: Version tags for stable releases (following semantic versioning)

## Governance

### Constitution Authority

This constitution governs all configuration changes. When conflicts arise between this constitution and other guidance, the constitution takes precedence.

### Amendment Process

1. **Proposal**: Document proposed change with rationale
2. **Review**: Discuss impact on existing configuration and workflow
3. **Update**: Increment version according to semantic versioning:
   - **MAJOR**: Remove or redefine core principles (backward-incompatible)
   - **MINOR**: Add new principles or materially expand guidance
   - **PATCH**: Clarifications, wording improvements, non-semantic changes
4. **Propagate**: Update dependent templates and documentation
5. **Communicate**: Summarize changes in commit message

### Compliance

- All configuration changes MUST align with Core Principles
- Technology constraints MUST be enforced for new dependencies
- Workflow conventions MUST be followed for commits and plugin management
- When principles conflict, prioritize Minimalism First and Native APIs

### Runtime Guidance

For day-to-day development work, refer to:
- **CLAUDE.md**: Project-specific instructions for Claude Code AI assistant
- **README.md**: User-facing documentation and setup instructions

**Version**: 1.0.0 | **Ratified**: 2025-03-15 | **Last Amended**: 2025-03-15
