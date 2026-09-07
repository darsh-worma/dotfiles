# dotfiles

loosely inspired from [Xiione/dotfiles](https://github.com/Xiione/dotfiles). 

- [Ghostty](https://ghostty.org/) (terminal emulator)
- [vim](https://www.vim.org/) (editor)
- [zsh](https://www.zsh.org/) (shell), with
  [oh-my-zsh](https://ohmyz.sh/) and
  [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Sioyek](https://sioyek.info/) (pdf viewer with vimtex sync)
- [yabai](https://github.com/koekeishiya/yabai) (window manager)
  - Pasted from [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles)
- [skhd.zig](https://github.com/jackielii/skhd.zig) (hotkey daemon)
  - Pasted from [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles)
- [sketchybar](https://felixkratz.github.io/SketchyBar/) (status bar replacement)
  - Modified from [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders) (window borders)
<br/><br/>


### Installation
1. `brew install stow`
2. Clone this repository to your home directory
3. `cd dotfiles` (this repository)
4. `stow .`
5. All done!

### Using this with a coding agent

[`AGENTS.md`](AGENTS.md) holds the working notes for this repo — the stow
layout and its constraints, which configs are live versus dormant, the
portability rules for `.zshrc`, and the caveats if you are not the original
owner. Point your agent at it before making changes. It is also symlinked as
`CLAUDE.md`, so Codex and Claude Code both pick it up automatically.

Set up git identity before committing:

```sh
cp .config/git/config.local.example ~/.config/git/config.local
$EDITOR ~/.config/git/config.local
```

### Prerequisites

`.zshrc` and `.p10k.zsh` are tracked here, but the machinery they drive is not:

- **zsh** (default on macOS; `apt install zsh` etc. on Linux)
- **oh-my-zsh** at `~/.oh-my-zsh`
- **powerlevel10k** at `~/.oh-my-zsh/custom/themes/powerlevel10k`
- **zsh-autosuggestions** at `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`
- A **Nerd Font**, for the prompt's icons

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### Remote Linux machines

To get the same prompt over ssh you only need `.zshrc` and `.p10k.zsh` plus the
packages above. The window-manager configs (sketchybar, yabai, skhd, borders,
karabiner, svim) are macOS-only and irrelevant on a server.

**The Nerd Font is only ever needed locally.** Over ssh the remote shell just
emits characters and escape codes; your local terminal renders them with its own
font. Never install fonts on the server.

`.zshrc` is written to be portable: conda, opam and the other machine-local
tool blocks are guarded, so a host missing them skips those blocks silently.

One host-side fix is worth doing once, because Ghostty advertises a `TERM` most
machines do not know:

```sh
infocmp -x xterm-ghostty | ssh HOST -- tic -x -
```

Without it `.zshrc` falls back to `TERM=xterm-256color` for ssh, which works but
gives up a few niceties.
