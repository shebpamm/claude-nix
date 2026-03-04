{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.default ];

  options = {
    kubernetes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kubernetes tools";
    };
  };

  config.package = pkgs.claude-code;
  config.extraPackages = lib.optionals config.kubernetes [ pkgs.mcp-k8s-go ];
  config.flags."--mcp-config" =
    let
      kubeMcpConfigStr = ''
          {
            "mcp_k8s": {
              "command": "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go",
              "args": []
            }
          }
        '';

      kubeMcpConfig = pkgs.writeTextFile {
        name = "kube-mcp-config.json";
        text = kubeMcpConfigStr;
      };

    in (lib.strings.join "," (
      lib.optional config.kubernetes kubeMcpConfig.outPath
      ));
}
