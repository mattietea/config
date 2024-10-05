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

2. In `flake.nix`, set `settings.hostname.personal` and `settings.hostname.work` to the respective hostnames

3. Remove all previous zsh related configs

```sh
rm -rf ~/.config/zsh
rm -rf ~/.zsh*
rm -rf ~/.oh-my-zsh
```

> This are some common places things get installed

4. Run the darwin build

```sh
cd ~/.config/nix

nix run nix-darwin -- switch --flake .#mac
```

> Installs `nix-darwin` and exposes the `darwin-rebuild` command

## Rebuild

```sh
cd ~/.config/nix

darwin-rebuild switch --flake .#mac
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

### Random

- [zellij](https://github.com/zellij-org/zellij) - A terminal workspace with batteries included
- [superkey](https://superkey.app/) - Keyboard enhancement
