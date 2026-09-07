# AGENTS.md

Working notes for coding agents in this repo. Read before changing anything.

## What this is

macOS dotfiles managed with GNU **stow**, derived from
[Xiione/dotfiles](https://github.com/Xiione/dotfiles) and since trimmed to the
tools actually in use.

## Hard constraint: do not move this directory

`stow` has linked ~15 symlinks from `$HOME` and `$HOME/.config` into this repo.
They are relative (`../dotfiles/.config/sketchybar`), so **the repo must stay at
`~/dotfiles`**. Moving or renaming it breaks the live setup. Work in place; never
relocate to "reorganise".

Home-level links: `.zshrc`, `.p10k.zsh`, `.vimrc`
`~/.config` links: `borders ghostty git karabiner neofetch sioyek sketchybar
skhd svim yabai`

After touching anything stow-managed, verify no link dangles:

```sh
for e in ~/.zshrc ~/.p10k.zsh ~/.vimrc ~/.config/*; do
  [ -L "$e" ] && { [ -e "$e" ] || echo "BROKEN $e"; }
done
```

## What the owner actually uses

Decisions here are driven by real usage, not by what upstream shipped.

- **Shell: zsh** (login shell). fish was removed; it was not even installed.
- **Editor: plain `vim`,** configured by `.vimrc`. Neovim is installed but has
  never been run (`~/.local/share/nvim` does not exist), so its 118-file config
  and the mcphub config were removed; recover them from upstream if it is ever
  picked up. Do not reintroduce a Neovim config speculatively.
- **Terminal: Ghostty.** iTerm2 and kitty were removed.
- **Live and load-bearing:** `sketchybar` (23 lua files, compiled C helpers in
  `helpers/*/bin`, `sketchybar.so` binding), `.zshrc`, `.p10k.zsh`.
- No C/C++ work (zero compiles in shell history), so no clangd config is kept.

## `.zshrc` portability contract

`.zshrc` must stay portable — it is deployed to remote Linux boxes for prompt
parity. Rules:

- **No hardcoded `/Users/darsh`.** Use `$HOME`.
- **Guard every machine-local block** (`conda`, `opam`, windsurf, antigravity,
  `~/.local/bin/env`) with an existence test, so a host lacking the tool skips it
  instead of erroring at shell start.
- Installer-appended lines (conda init, `uv`, etc.) routinely violate both rules.
  Re-guard them after any tool rewrites the file.

Verify a change is still portable:

```sh
zsh -n ~/.zshrc
env -i HOME=/tmp/fakehome ZDOTDIR=/tmp/fakehome TERM=xterm-256color \
  PATH=/usr/bin:/bin /bin/zsh -i -c 'echo ok'   # must print ok, no errors
```

## Remote Linux notes

- Only `.zshrc` + `.p10k.zsh` are needed for prompt parity. sketchybar, yabai,
  skhd, borders, karabiner and svim are macOS-only.
- **Never install fonts on a remote host.** Over ssh the remote shell only emits
  characters and escape codes; the *local* terminal renders them with its own
  Nerd Font.
- Ghostty advertises `TERM=xterm-ghostty`, absent from most hosts' terminfo.
  `.zshrc` wraps `ssh` to fall back to `xterm-256color`. The durable per-host fix
  is `infocmp -x xterm-ghostty | ssh HOST -- tic -x -`.

## Git config is deliberately split

`.config/git/config` is tracked and carries only shared settings (lfs, ssh
signing format, default branch). Identity — `user.name`, `user.email`,
`user.signingkey`, `commit.gpgsign` — lives in `~/.config/git/config.local`,
which is **gitignored**, with `config.local.example` as the template.

Never move identity back into the tracked file. This repo is public, and anyone
who clones and stows it would otherwise author and sign commits as the repo
owner. If `config.local` is missing, git refuses to commit rather than
misattributing — that is the intended failure mode.

## Conventions

- Home-level dotfiles (`.zshrc`, `.vimrc`, `.p10k.zsh`) follow the pre-XDG
  convention; everything modern lives under `.config/`. Keep new configs in
  `.config/` unless the tool insists otherwise.
- `.p10k.zsh` stays at `~/.p10k.zsh`. It is sourced by one explicit line in
  `.zshrc`, but `p10k configure` writes to that path unconditionally, so moving
  it causes silent divergence.
- Vim writes `*.un~` undo files next to edited files; these are gitignored and
  must never be committed (they embed deleted buffer text).

## If you are not the repo owner

This is one person's setup. Cloning it wholesale has sharp edges:

- **`stow .` refuses to overwrite real files.** If a target like `~/.zshrc`
  already exists as a regular file, stow reports a conflict and skips it rather
  than clobbering it. The skip is easy to miss — the repo's own `.zshrc` sat
  unlinked for months this way, silently diverging from the tracked copy. After
  stowing, confirm the links you expected actually exist.
- **`karabiner.json` is bound to specific hardware.** It carries `vendor_id` /
  `product_id` pairs for four devices; those rules will not match another
  person's keyboard.
- **sketchybar needs a toolchain.** The compiled helpers under `helpers/*/bin`
  are gitignored; `helpers/init.lua` shells out to `make` on first load.
- **Identity is not included** by design; see the git config section above.

## Before committing

The repo is public. Run a secret scan over staged content, not just the diff:

```sh
git diff --cached | grep -E '^\+' | grep -iE \
  'sk-[A-Za-z0-9_-]{16,}|ghp_|AKIA[0-9A-Z]{12,}|BEGIN [A-Z ]*PRIVATE KEY'
```

Known-benign hit: `["1Password"] = ":one_password:"` in
`sketchybar/helpers/app_icons.lua`.
