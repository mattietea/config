let
  app = name: ../modules/home-manager/applications/${name};
  pkg = name: ../modules/home-manager/packages/${name};
in
{
  inherit app pkg;

  commonVariables = {
    EDITOR = "zed --wait";
    VISUAL = "zed --wait";
  };

  commonApps = map app [
    "ghostty"
    "zed"
    "orca"
  ];

  commonPackages = map pkg [
    "agenix"
    "aerospace"
    "bat"
    "bun"
    "dock"
    "delta"
    "devenv"
    "direnv"
    "eza"
    "fonts"
    "fzf"
    "gh"
    "git"
    "git-absorb"
    "git-machete"
    "lazygit"
    "mise"
    "node"
    "pure"
    "rename-utils"
    "tldr"
    "zoxide"
    "zsh"
  ];
}
