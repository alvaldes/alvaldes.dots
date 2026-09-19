# alvaldes.dots

Personal macOS configuration, versioned so a new machine can be brought back to
the same state.

## Layout

The repository root **is** `~/.config`, and an extra `home/` directory holds the
files that belong directly in `$HOME`.

```text
~/.config/                  <- this repository
├── home/                   -> symlinked into $HOME by install.sh
│   ├── .zshrc  .zprofile  .zshenv        zsh
│   ├── .profile  .bash_profile           POSIX / bash
│   ├── .gitconfig  .gitignore_global     git
│   ├── .tmux.conf  .p10k.zsh
│   └── .condarc  .hushlogin
├── templates/              secret templates, never linked
│   ├── .wakatime.cfg.example
│   ├── .aicommits.example
│   └── .openvpn-connect.json.example
├── nvim/  ghostty/  zellij/  btop/  sketchybar/  ...
├── tmux/                   agent-state display layer for tmux
├── agent-state/            agent-state reporter scripts
├── mcp/                    MCP server registry
├── scripts/                fetch-zellij-plugins.sh
├── .githooks/              pre-commit secret scan
├── .github/workflows/      CI secret scan
├── .betterleaks.toml       scanner config and allowlists
├── install.sh
└── .gitignore
```

Everything outside `home/` mirrors `~/.config/<dir>` one to one, so cloning the
repository into `~/.config` puts those files in place with no extra step.

`home/` holds only files that `install.sh` links. Templates and other
non-linked references live outside it, so nothing can be linked by accident.

## Install on a new machine

```sh
git clone https://github.com/alvaldes/alvaldes.dots.git ~/.config
~/.config/install.sh --dry-run   # review the plan
~/.config/install.sh             # create the symlinks in $HOME
exec zsh -l
```

`install.sh` replaces an existing `$HOME` file by moving it into
`~/.dotfiles-backup-<timestamp>/` first, and re-running it is safe: an
already-correct symlink is reported and skipped.

Then restore the files that are deliberately **not** versioned — see below —
using the matching `templates/*.example` reference.

### After cloning

This repository keeps hand-written configuration only. Some runtime assets are
**not** duplicated here because they come from the upstream
[Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots)
installer. Restore them by re-running that installer, or by copying them out of
its tree.

- **Zellij plugins.** `zellij/config.kdl` and every `zellij/layouts/*.kdl`
  reference `file:~/.config/zellij/plugins/{zjstatus,zellij_forgot}.wasm`. Those
  are local `file:` paths, so Zellij does **not** fetch them and a fresh clone
  has an empty `zellij/plugins/`. Run:

  ```sh
  ~/.config/scripts/fetch-zellij-plugins.sh
  ```

  The script downloads both from the upstream Gentleman.Dots repository and
  verifies each file against a pinned SHA-256 before installing it.
- **Neovim spelling.** Only the curated word list `nvim/spell/en.utf-8.add` is
  versioned, because it is the one file that is genuinely personal. The base
  dictionary `en.utf-8.spl` ships inside Neovim's own runtime, and Neovim
  prompts to download any other missing language from
  `https://ftp.nluug.nl/pub/vim/runtime/spell`. The large raw word lists
  (`en_words.txt`, `es_words.txt`, `en_custom.txt`) are upstream installer
  artifacts and are not needed at runtime.
- **Ghostty shaders.** `ghostty/config` references exactly one,
  `cursor_smear_gentleman.glsl`, which is tracked. The other 51 arrived as a
  single bulk third-party download and are not versioned.

## What is never versioned, and why

Rule: configuration is versioned, credentials are not. Files inside this
repository are excluded by `.gitignore`; the rest never enter it because they
live outside the repository root. Each one has a `.example` template under
`templates/` where the shape is worth documenting.

| File | Contains | Handling |
| --- | --- | --- |
| `~/.wakatime.cfg` | plaintext WakaTime API key | ignored, `templates/.wakatime.cfg.example` |
| `~/.aicommits` | plaintext OpenAI key | ignored, `templates/.aicommits.example` |
| `~/.openvpn-connect.json` | VPN hostnames and usernames | ignored, `templates/.openvpn-connect.json.example` |
| `~/.config/opencode/opencode.json` | private endpoints, rewritten by tokenharbor | ignored |
| `~/.claude.json` | user id, project list, prompt history | outside the repository |
| `~/.tokenharbor/` | the credential store itself | outside the repository |
| `~/.config/codexbar/` | plaintext tokens | ignored |
| `~/.config/nan/` | plaintext tokens | ignored |
| `~/.ssh/` | private keys | outside the repository |
| shell history (`~/.zsh_history`, `~/.bash_history`, `~/.python_history`, `~/.zhistory`) | commands, paths, pasted secrets | outside the repository |

### Credential injection hazard

`tokenharbor` writes API keys directly into these files:

```text
~/.claude/settings.json          ~/.codex/config.toml
~/.config/opencode/opencode.json ~/.continue/config.json
~/.pi/agent/models.json
```

None of them is versioned today. **Do not add any of them to this repository** —
doing so would publish live credentials on the next commit. If one of these ever
needs versioning, version a `.example` template and keep the real file ignored.

Near-miss worth knowing: `.claude/settings.json` *is* tracked, but that is
`~/.config/.claude/settings.json`, a repository-local Claude Code config — a
different file, with a different inode, from the `~/.claude/settings.json` that
tokenharbor rewrites. If `~/.claude` ever becomes a symlink into this
repository, the next commit publishes live keys.

## Secret scanning

This repository is public, so a committed secret is published the moment it is
pushed. Two layers guard against it, plus one manual recipe for forensics.

```sh
# What the pre-commit hook runs, on demand:
betterleaks git --pre-commit --staged --redact

# Full history:
betterleaks git . --redact

# Everything tracked in the working tree:
betterleaks dir . -c .betterleaks.toml --redact
```

`install.sh` points `core.hooksPath` at `.githooks/`, so a fresh clone gets the
pre-commit hook. The hook refuses to commit when a known credential vault is
staged, or when the staged content trips a scanner rule. Bypass one commit with
`SKIP=betterleaks git commit ...` for a confirmed false positive, then add an
allowlist entry to `.betterleaks.toml`.

Install the scanner with `brew install betterleaks`. The hook fails open with a
warning if it is missing, so an uninstalled optional tool never blocks a commit.

### The blind spot: read this before trusting a clean scan

Both betterleaks and gitleaks scan with `git log -p --all`. That sees only
commits **reachable from refs**. A credential that was pushed and later rewritten
out of history survives as a dangling object and is **invisible to both tools**.
Verified empirically, not assumed:

| Method | Finds a rewritten-out secret? |
| --- | --- |
| `git log -p --all` (what the scanners run) | **no** |
| `git rev-list --all` + `git grep` | **no** |
| `git log -p --reflog` | yes, while the reflog survives |
| `git cat-file --batch-all-objects --batch` | **yes** |
| `git fsck --unreachable` locally | no — a reflog-reachable object counts as reachable |
| `git fsck --unreachable` on a bare remote | **yes** — the remote has no reflog |

Consequences worth keeping straight:

- **Scanners are prevention, not forensics.** Neither one would have found the
  credential that leaked from this repository.
- **To audit, use the object store.** A clean scanner run is not proof of a clean
  repository.
- **A supported way to see rewritten-out commits**, before the reflog is purged:

  ```sh
  betterleaks git --log-opts="--reflog --all" .
  ```

  Note that `--log-opts` **replaces** the scanner's default arguments, so `--all`
  must be passed again or only HEAD is scanned. Once the reflog is gone this scan
  returns clean **by vacuity**, which is not the same as clean. Never confuse the
  two.
- **Rewriting history is not a fix.** GitHub keeps serving an unreachable object
  by its SHA even after a force-push. Rotate the credential; that is the only
  real remediation.

### Why betterleaks and not gitleaks

gitleaks is feature complete and gets security patches only; its author moved to
betterleaks, which carries the `validate` feature: it proves whether a detected
secret is still live by making a request, instead of guessing. Install it with
`brew install betterleaks`.

## Adding new configuration

1. Add the file where the tool reads it — `home/` for `$HOME`, or the matching
   `~/.config/<dir>` path otherwise.
2. Run `git status` and confirm the file is meant to be public: this repository
   is **public on GitHub**.
3. If it contains a secret, add a `.example` template under `templates/` and an
   ignore rule instead.
4. Keep generated files out. `git status` should show only hand-written files;
   `/tmp`-style artifacts, caches, lockfiles of downloaded binaries, and build
   output belong in `.gitignore`.

## Notes

- Commit messages follow Conventional Commits.
- Known follow-up: `tmux/scripts/` and `agent-state/scripts/` both come from the
  external `gentle-agent-state` installer and overlap
  (`tmux/scripts/agent-report.sh` is byte-identical to
  `agent-state/scripts/tmux-agent-report.sh`). Deduplicating them changes live
  tmux notifier behavior, so it is pending.
- `~/.gitconfig` sets `core.excludesFile = ~/.gitignore_global`, so the tracked
  `git/ignore` file is currently unused and its rule
  (`**/.claude/settings.local.json`) is not enforced today. Kept for
  compatibility with the Gentleman.Dots installer; wiring it up would mean
  dropping the `core.excludesFile` line, since Git already reads
  `$XDG_CONFIG_HOME/git/ignore` by default.
