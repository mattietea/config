{
  pkgs,
  inputs,
  settings,
  ...
}:
let
  dataDir = "/Users/${settings.username}/.local/share/whatsapp-mcp";

  whatsappBridge = pkgs.buildGoModule {
    pname = "whatsapp-bridge";
    version = inputs.whatsapp-mcp-src.shortRev or "unstable";

    src = "${inputs.whatsapp-mcp-src}/whatsapp-bridge";

    vendorHash = "sha256-CALWPlMNnmI7ijELY7RH6dx+47P88AEq0S9dJawsYOY=";

    env.CGO_ENABLED = "1";

    subPackages = [ "." ];

    meta = {
      description = "WhatsApp Web bridge for whatsapp-mcp";
      homepage = "https://github.com/lharries/whatsapp-mcp";
      license = pkgs.lib.licenses.mit;
    };
  };

  whatsappMcpServer = pkgs.stdenv.mkDerivation {
    pname = "whatsapp-mcp-server";
    version = inputs.whatsapp-mcp-src.shortRev or "unstable";
    src = "${inputs.whatsapp-mcp-src}/whatsapp-mcp-server";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
      substituteInPlace $out/whatsapp.py \
        --replace-fail \
        "os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'whatsapp-bridge', 'store', 'messages.db')" \
        "'${dataDir}/store/messages.db'"
    '';
  };
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "whatsapp-bridge" ''
      mkdir -p "${dataDir}/store"
      cd "${dataDir}"
      exec ${whatsappBridge}/bin/whatsapp-client "$@"
    '')
  ];

  launchd.agents.whatsapp-bridge = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.writeShellScript "whatsapp-bridge-launchd" ''
          mkdir -p "${dataDir}/store"
          cd "${dataDir}"
          exec ${whatsappBridge}/bin/whatsapp-client
        ''}"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${dataDir}/bridge.log";
      StandardErrorPath = "${dataDir}/bridge.err";
    };
  };

  programs.mcp.servers.whatsapp = {
    type = "stdio";
    command = "${pkgs.writeShellScript "whatsapp-mcp-server" ''
      export UV_PROJECT_ENVIRONMENT="${dataDir}/.venv"
      exec ${pkgs.uv}/bin/uv --directory ${whatsappMcpServer} run --frozen main.py
    ''}";
    args = [ ];
  };
}
