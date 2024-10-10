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
   3. hostnames (eg. "Matts-Work-MacBook-Pro")

1. Run the darwin build

```sh
(cd ~/.config/nix && nix run nix-darwin -- switch --flake .)
```

> Installs `nix-darwin` and exposes the `darwin-rebuild` command

## Rebuild

```sh
(cd ~/.config/nix && darwin-rebuild switch --flake .)
```

## Formatting

```sh
nix fmt
```

### Examples

- [tbreslein/dots](https://github.com/tbreslein/dots/blob/main/flake.nix)
- [sukhmancs/nixos-configs](https://github.com/sukhmancs/nixos-configs)
- [zupo/dotfiles](https://github.com/zupo/dotfiles/blob/main/flake.nix)
- [pcasaretto/nix-home](https://github.com/pcasaretto/nix-home)
- [nix-darwin-dotfiles](https://github.com/shaunsingh/nix-darwin-dotfiles)

### Random

- [zellij](https://github.com/zellij-org/zellij) - A terminal workspace with batteries included
- [hhtwm - window manager](https://github.com/szymonkaliski/hhtwm)
- [devhints](https://devhints.io)
- [tldr](https://github.com/tldr-pages/tldr?tab=readme-ov-file)
- [superkey](https://superkey.app/) - Keyboard enhancement
- [roundy](https://github.com/nullxception/roundy) - zsh prompt
- [dreams of autonomy zsh cfg](https://www.youtube.com/watch?v=ud7YxC33Z3w)
