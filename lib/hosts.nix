let
  app = name: ../modules/home-manager/applications/${name};
  pkg = name: ../modules/home-manager/packages/${name};
  # Packages with no config beyond installing one nixpkgs attr — declared inline
  # rather than each getting its own module directory.
  trivialPkg = attr: { pkgs, ... }: { home.packages = [ pkgs.${attr} ]; };
in
{
  inherit app pkg trivialPkg;

  commonVariables = {
    EDITOR = "zed --wait";
    VISUAL = "zed --wait";
  };

  commonApps = map app [
    "ghostty"
    "zed"
    "orca"
  ];

  commonPackages =
    map pkg [
      "agenix"
      "aerospace"
      "bat"
      "bun"
      "dock"
      "delta"
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
      "pure"
      "rename-utils"
      "tldr"
      "zoxide"
      "zsh"
    ]
    ++ map trivialPkg [
      "devenv"
      "mole"
      "nodejs"
    ];
}
