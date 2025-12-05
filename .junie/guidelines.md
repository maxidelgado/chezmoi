Project-specific development guidelines

1. Build and configuration

- Prerequisites
  - Chezmoi (latest stable).
  - 1Password CLI (`op`) signed in with an account that contains the vaults referenced by templates.
  - Git and Homebrew (macOS), zsh.
  - Optional: asdf, direnv, Neovim 0.10+.

- Chezmoi bootstrap
  - This repository is a chezmoi-managed dotfiles setup. The root template `.chezmoi.toml.tmpl` drives per-machine data and secrets injection.
  - First-time init (recommended on a fresh system):
    - Sign in to 1Password CLI: `op account add` then `op signin`.
    - Run: `chezmoi init --apply <repo>` or if already cloned, from repo root: `chezmoi apply`.
    - On first apply, chezmoi will prompt via `promptStringOnce` for:
      - `system_username`, `company`, `first_name`, `last_name`, `personal_email`, `work_email`, and versions for `golang`, `rust`, `nodejs`, `python`, and `work_git_host`.
    - These values are cached by chezmoi and reused on subsequent applies.

- Secrets and 1Password integration
  - Templates call `onepasswordRead` to pull secrets. Key lookups are constructed from the `company` value. For example:
    - AWS: `op://<company>/aws-credentials/{access_key,secret_key,region}`
    - SSH keys: `op://personal/ssh-key/public key` and `op://<company>/ssh-key/public key`
  - Ensure these items exist with the exact item and field names. If your vault uses different names, either create aliases or adjust the template paths before apply.

- Generated files overview
  - AWS: `~/.aws/credentials` and `~/.aws/config` come from `dot_aws/*.tmpl` and consume `.aws_access_key`, `.aws_secret_key`, and `.aws_region` originating in `.chezmoi.toml.tmpl` via 1Password.
  - Git: `dot_gitconfig.tmpl` and `private_dot_gitconfig_work.tmpl` use name/email/signing key paths from `.chezmoi.toml.tmpl`.
  - SSH: `dot_ssh/*.tmpl` uses public keys from 1Password items.
  - Tool versions: `dot_tool-versions.tmpl` is parameterized by the language version prompts; ensure asdf is installed if you rely on it.
  - Brew: `dot_Brewfile` is available; run `brew bundle` post-apply if desired.
  - Run-once installer: `run_once_install-packages.sh.tmpl` is executed automatically by chezmoi on first apply; review before the first run on a new machine.

2. Neovim configuration

- Entry point: `~/.config/nvim/init.lua` sets up the `vnext` namespace and requires `vnext.config`.
- Plugin manager: `lazy.nvim` is bootstrapped in `dot_config/nvim/lua/vnext/config/lazy.lua`.
  - Lockfile path is `~/.lazy-lock.json` (outside the repo). Plugin updates won’t modify this repository.
- Useful checks:
  - `:checkhealth` (after first start) to validate provider/tooling.
  - `:Lazy` to inspect plugin state, updates, and logs.
- Linting/style for Lua:
  - Selene configuration is in `dot_config/nvim/selene.toml`. If `selene` is installed, you can lint the config:
    - `cd ~/.config/nvim && selene .` (or point to the repo’s `dot_config/nvim` directory before applying).

3. Go helper utility (dot_mover)

- The `dot_mover/` directory contains a small Go utility that depends on `robotgo` and several OS-specific packages.
- It is not required for basic bootstrap. If you intend to build it locally:
  - Ensure Go is installed (the repo captures desired versions via prompts for `.tool-versions`).
  - From `dot_mover/`: `go mod download && go build`.
  - Note: Dependencies are platform-sensitive; expect different behavior across macOS/Linux/Windows.

4. Testing: project-specific validation

- Rationale: Because this is a dotfiles/chezmoi repository, most “tests” are invariants about templates and structure rather than unit tests. We recommend simple bash validations that verify critical template hooks remain intact.

- Running an example validation (used to verify this document)
  - We executed the following temporary script from the repo root to confirm key invariants:

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

  - All checks passed on 2025-12-05 18:16 local time.

- Adding new validations
  - Place bash scripts under a dedicated directory (suggested: `.junie/tests/`), each exiting non-zero on failure.
  - Keep checks repository-local and independent of network calls to maximize portability.
  - Typical targets to validate:
    - Presence and names of `onepasswordRead` paths and `promptStringOnce` prompts in `.chezmoi.toml.tmpl`.
    - Existence and schema of `dot_aws/*.tmpl`, `dot_ssh/*.tmpl`, and key Neovim entry points.
    - Sanity checks for run-once scripts not to be re-entrant when not intended.
  - To run all tests: `for f in .junie/tests/*.sh; do bash "$f" || exit 1; done`

5. Development conventions

- Templates (chezmoi)
  - Prefer `promptStringOnce` for machine/user-level constants and keep secret values fetched via `onepasswordRead` only.
  - Derive computed values in `.chezmoi.toml.tmpl` (e.g., `full_name`, `work_git_https_url`) to avoid duplication.

- Lua (Neovim)
  - Follow the existing module layout under `lua/vnext/` with `config/` and `plugins/` split.
  - Keep plugin-specific config co-located in `lua/vnext/plugins/<topic>.lua` to minimize cross-file coupling.
  - Avoid writing to repo during runtime; lazy lockfile is intentionally outside the repo.

- Go (dot_mover)
  - Keep the module self-contained; no cross-imports from the rest of the repo.
  - Avoid introducing CGo unless strictly necessary; `robotgo` already pulls platform bindings.

- Shell scripts
  - Use `set -euo pipefail` and explicit non-zero exits on failure.
  - Aim for idempotence in `run_once_*` scripts; guard repeated execution if side effects are costly.
