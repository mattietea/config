# Config

An attempt to use [Nix](https://nixos.org/download/) for my dotfiles

> I have no idea what I'm doing - don't use this as an example

**Modules**

- [Darwin](https://github.com/LnL7/nix-darwin)
- [Home manager](https://github.com/nix-community/home-manager)

## Setup

1. Clone the repo

```sh
git clone https://github.com/mattietea/config ~/.config/nix
```

2. In `flake.nix` update

   1. username
   2. email
   3. hostnames (scutil --get LocalHostName)

1. Run the darwin build

```sh
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .
```

> Installs `nix-darwin` and exposes the `darwin-rebuild` command

## Rebuild

```sh
darwin-rebuild switch --flake .
```

## Formatting

```sh
nix fmt
```

### TODO

- [x] Add `qmv` for bulk renaming files
- [x] Update EDITOR and VISUAL env variables
- [ ] Add zoxide
- [ ] Update ZSH config to defer plugins (fix zsh-autocomplete)
- [ ] Figure out Homebrew

### Examples

- [tbreslein/dots](https://github.com/tbreslein/dots/blob/main/flake.nix)
- [sukhmancs/nixos-configs](https://github.com/sukhmancs/nixos-configs)
- [zupo/dotfiles](https://github.com/zupo/dotfiles/blob/main/flake.nix)
- [pcasaretto/nix-home](https://github.com/pcasaretto/nix-home)
- [nix-darwin-dotfiles](https://github.com/shaunsingh/nix-darwin-dotfiles)
- [christoomey/dotfiles](https://github.com/christoomey/dotfiles)

### Random

- [zellij](https://github.com/zellij-org/zellij) - A terminal workspace with batteries included
- [hhtwm - window manager](https://github.com/szymonkaliski/hhtwm)
- [devhints](https://devhints.io)
- [tldr](https://github.com/tldr-pages/tldr?tab=readme-ov-file)
- [superkey](https://superkey.app/) - Keyboard enhancement
- [roundy](https://github.com/nullxception/roundy) - zsh prompt
- [dreams of autonomy zsh cfg](https://www.youtube.com/watch?v=ud7YxC33Z3w)
- [maple font](https://github.com/subframe7536/maple-font/)
- [precommit checks](https://github.com/dc-tec/nixvim/blob/main/flake.nix#L43-L49)
- vim
  - [telescope](https://github.com/nvim-telescope/telescope.nvim)
  - [Vim: Tutorial on Editing, Navigation, and File Management](https://www.youtube.com/watch?app=desktop&v=E-ZbrtoSuzw)
  - [vim-which-key](https://github.com/liuchengxu/vim-which-key)
  - [oil](https://github.com/stevearc/oil.nvim)
  - [mini](https://github.com/echasnovski/mini.nvim)
  - [clue](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-clue.md)
