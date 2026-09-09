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
  ];

  commonPackages =
    map pkg [
      "agenix"
      "aerospace"
      "bat"
      "bun"
      "delta"
      "direnv"
      "eza"
      "fonts"
      "fzf"
      "gh"
      "gh-stack"
      "git"
      "git-absorb"
      "herdr"
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
