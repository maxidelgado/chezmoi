Chezmoi Dotfiles with 1Password, Neovim, and Optional Go Helper

This repository contains a chezmoi-managed dotfiles setup. It bootstraps a development environment on macOS (and partially Linux/Windows for specific tools) with:

- Chezmoi templates and run-once bootstrap scripts
- 1Password CLI-backed secrets injection
- Neovim configuration (Lua) managed via lazy.nvim
- Optional Go helper utility (`dot_mover/`)
- Brew bundle and common shell tooling

The configuration is parameterized via prompts on first apply and pulls secrets from 1Password vaults.


## Requirements

- Chezmoi (latest stable)
- 1Password CLI (`op`) signed in to an account that contains the referenced vault items
- Git and Homebrew (on macOS), zsh
- Optional tools the config can leverage:
  - asdf (for language version management via `.tool-versions`)
  - direnv
  - Neovim 0.10+
  - selene (for Lua linting) — optional
  - Go (to build the optional `dot_mover` utility)


## Stack and Entry Points

- Chezmoi root template: `.chezmoi.toml.tmpl`
  - Drives per-machine data, sets up prompts via `promptStringOnce`, and wires 1Password secret lookups via `onepasswordRead`.
- Neovim configuration:
  - Entry: `dot_config/nvim/init.lua` which requires `vnext.config`
  - Plugin manager bootstrap: `dot_config/nvim/lua/vnext/config/lazy.lua` (uses `lazy.nvim`)
- Go helper utility: `dot_mover/` (`go.mod`, `main.go`)
- Run-once script: `run_once_install-packages.sh.tmpl` (executed automatically by chezmoi on first apply)


## Setup

1. Sign in to 1Password CLI
   - Add account: `op account add`
   - Sign in: `op signin`

2. First-time Chezmoi apply
   - If starting fresh (recommended):
     - `chezmoi init --apply <repo>`
   - If you already cloned this repo to a directory (this repo root):
     - `chezmoi apply`

3. Answer prompts on first apply
   - Chezmoi will ask (via `promptStringOnce`) for values like:
     - `system_username`, `company`, `first_name`, `last_name`, `personal_email`, `work_email`
     - Language versions: `golang`, `rust`, `nodejs`, `python`
     - `work_git_host`
   - These are cached by chezmoi and reused on subsequent applies.

4. Ensure 1Password items exist
   - Templates expect items/fields constructed using the `company` value, e.g.:
     - AWS: `op://<company>/aws-credentials/{access_key,secret_key,region}`
     - SSH keys: `op://personal/ssh-key/public key` and `op://<company>/ssh-key/public key`
   - If your vault names differ, either create aliases or adjust the template paths before applying.


## Running and Daily Use

- Re-apply changes after editing templates/files in this repo:
  - `chezmoi apply`
- After first apply, you may want to install brew packages:
  - `brew bundle --file dot_Brewfile`
- Neovim
  - On first launch, lazy.nvim will bootstrap automatically
  - Check status/logs: `:Lazy`
  - Health checks: `:checkhealth`


## Scripts and Utilities

- Run-once installer (auto-run by chezmoi on first apply):
  - `run_once_install-packages.sh.tmpl`
- Brew bundle:
  - `brew bundle --file dot_Brewfile`
- Go helper utility (optional):
  - Build locally: `cd dot_mover && go mod download && go build`
  - Launch/install specifics may be platform-dependent; see `dot_mover/install.sh` and `dot_mover/com.mdelgado.mover.plist.template` (macOS LaunchAgent).


## Environment and Secrets

- 1Password CLI must be signed in prior to `chezmoi apply` so that `onepasswordRead` template calls can resolve.
- This repo does not store secrets; secrets are fetched at template render time from 1Password.
- AWS and SSH configurations are generated from templates:
  - AWS templates: `dot_aws/credentials.tmpl`, `dot_aws/config.tmpl`
  - SSH templates: `dot_ssh/*.tmpl`


### Environment Variables

- This repo does not require custom environment variables to apply.
- Chezmoi and the 1Password CLI use their standard environment configuration; ensure `op signin` has been completed in your shell/session.
- TODO: Document any environment variables introduced by future `run_once_*` scripts or additions.


## Testing and Validations

This is a dotfiles/chezmoi repository; validations focus on invariant checks for template hooks and key files. Example validation script used during authoring:

```
#!/usr/bin/env bash
set -euo pipefail
fail=0
pass() { printf "PASS: %s\n" "$1"; }
failf() { printf "FAIL: %s\n" "$1"; fail=1; }
check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then pass "$desc"; else failf "$desc"; fi
}
check "Chezmoi main template exists" test -f .chezmoi.toml.tmpl
check "Chezmoi uses promptStringOnce" grep -q promptStringOnce .chezmoi.toml.tmpl
check "Chezmoi integrates 1Password via onepasswordRead" grep -q onepasswordRead .chezmoi.toml.tmpl
check "AWS credentials template maps keys" bash -c "grep -q 'access_key = {{ .aws_access_key }}' dot_aws/credentials.tmpl && grep -q 'secret_key = {{ .aws_secret_key }}' dot_aws/credentials.tmpl"
check "AWS config template exists" test -f dot_aws/config.tmpl
check "Neovim init.lua present" test -f dot_config/nvim/init.lua
check "Neovim init.lua requires vnext.config" grep -Fq 'require("vnext.config")' dot_config/nvim/init.lua
check "lazy.nvim bootstrap present" grep -Fq 'require("lazy").setup' dot_config/nvim/lua/vnext/config/lazy.lua
check "mover go.mod present" test -f dot_mover/go.mod
exit $fail
```

Add your own repository-local validations under a directory like `.junie/tests/` and run them with:

```
for f in .junie/tests/*.sh; do bash "$f" || exit 1; done
```


## Linting and Style

- Lua: Selene config at `dot_config/nvim/selene.toml`
  - If `selene` is installed, you can lint the config:
    - `cd ~/.config/nvim && selene .` (or point to this repo’s `dot_config/nvim` prior to apply)
- Chezmoi templates: prefer `promptStringOnce` for constants; secrets via `onepasswordRead`.
- Go (`dot_mover`): self-contained module; avoid introducing CGo unless necessary.
- Shell scripts: use `set -euo pipefail`; aim for idempotence in `run_once_*` scripts.


## Project Structure

Key paths in this repo:

- `.chezmoi.toml.tmpl` — Main chezmoi template with prompts and 1Password integration
- `dot_Brewfile` — Homebrew bundle list
- `dot_aws/` — AWS config and credentials templates
- `dot_config/nvim/` — Neovim configuration (Lua), plugins under `lua/vnext/plugins/`
- `dot_mover/` — Optional Go helper utility (`go.mod`, `main.go`, install assets)
- `dot_ssh/` — SSH config and public key templates
- `dot_tool-versions.tmpl` — Versions for asdf
- `run_once_install-packages.sh.tmpl` — Run-once installer script
- `dot_wezterm.lua` — WezTerm configuration
- `dot_gitconfig.tmpl`, `private_dot_gitconfig_work.tmpl` — Git configuration templates
- `dot_zshrc.tmpl`, `dot_config/direnv/config.toml.tmpl`, `dot_config/starship.toml` — Shell and prompt configs


## Neovim Notes

- Entry: `~/.config/nvim/init.lua` after apply
- Plugin manager: `lazy.nvim`, lockfile is outside this repo at `~/.lazy-lock.json`
- Use `:Lazy` for plugin state/logs and `:checkhealth` for environment checks


## License

- TODO: Add license. If this repository is intended to be public or shared, include a `LICENSE` file (e.g., MIT, Apache-2.0). If private, document usage restrictions here.


## Troubleshooting

- 1Password secrets not found: verify `op signin` and that item names/fields match the paths used in `.chezmoi.toml.tmpl`.
- Re-running run-once scripts: guard against unintended re-entry; inspect `run_once_*` behavior before re-triggering.
- Go helper build issues: dependencies are platform-sensitive; ensure a supported OS and an installed Go toolchain.
