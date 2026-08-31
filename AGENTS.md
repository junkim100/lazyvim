# LazyVim Agent Rules

## Scope

This repository is a standalone personal LazyVim configuration. `install.sh` installs the pinned Neovim release, links this checkout to `~/.config/nvim`, restores locked plugins, and provisions available Mason tools.

## Ownership

- `install.sh` owns Neovim installation, release checksums, dependency checks, the config symlink, plugin restoration, and Mason bootstrap invocation.
- `lazy-lock.json` pins LazyVim and every Neovim plugin to exact commits.
- `lazyvim.json` pins enabled LazyVim extras.
- `lua/config/` owns core Neovim options, keymaps, autocommands, and lazy.nvim bootstrap.
- `lua/plugins/` owns plugin additions and LazyVim overrides.
- `bootstrap-mason.lua` owns the requested language server, formatter, and linter package set.
- `README.md` records reproducibility boundaries, dependencies, and intentional deviations from stock LazyVim.

## Safety

- Never commit credentials, tokens, machine-generated state, caches, logs, session data, or private environment files.
- Preserve unrelated tracked modifications and untracked files. Never stage them as part of another task.
- Edit this checkout rather than treating the `~/.config/nvim` symlink as a separate configuration source.
- Do not use broad staging commands when unrelated work exists. Stage explicit paths.
- Do not commit or push unless the user explicitly requests it.
- Do not run `Lazy! sync` or update all plugins unless the task intentionally changes pinned revisions.
- Do not claim Mason-managed external tools are version-pinned because they are installed by package name from the current registry.

## Changes

- Reuse LazyVim and lazy.nvim conventions already present in the repository. Do not introduce a second plugin configuration pattern.
- Merge LazyVim-provided option tables instead of replacing extendable lists such as `ensure_installed` or `formatters_by_ft`.
- Keep `lazy-lock.json` unchanged for configuration-only edits.
- When intentionally changing plugins, update the lockfile, inspect every changed revision, and retain only requested dependency changes.
- Update `README.md` when observable editor behavior, dependencies, installation, keymaps, or reproducibility boundaries change.
- Remove obsolete plugins, settings, comments, and compatibility paths during a clean migration.
- Keep prose to one logical line per paragraph, list item, or heading.
- Do not use em dashes or en dashes in prose.
- Publish changes in this repository before updating the `lazyvim` submodule pointer in `junkim100/dotfiles`.

## Verification

- Format changed Lua files with `stylua`.
- Format `install.sh` with `shfmt` when it changes, then run `bash -n install.sh`.
- Run `Lazy! restore` after plugin or lockfile changes.
- Start Neovim headlessly and confirm the expected colorscheme and configuration load without errors.
- Launch interactive Neovim for visual changes and exercise the affected surface.
- Run the dedicated installer when installation, symlink, dependency, theme, or plugin bootstrap behavior changes.
- Run `git diff --cached --check` before committing.
- After pushing, update and verify the parent dotfiles submodule with `git submodule status --recursive`.
