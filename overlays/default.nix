final: _prev:
let
  sources = final.callPackage ../_sources/generated.nix { };
in
{
  pup = final.callPackage ../modules/home-manager/packages/pup/package.nix {
    inherit (sources.pup) version src;
  };

  linear-cli = final.callPackage ../modules/home-manager/packages/linear/package.nix {
    inherit (sources.linear) version src;
  };

  wacli = final.callPackage ../modules/home-manager/packages/wacli/package.nix {
    inherit (sources.wacli) version src;
  };

  mole = final.callPackage ../modules/home-manager/packages/mole/package.nix {
    inherit (sources.mole) version src;
  };
}
