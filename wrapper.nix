{ config
, wlib
, lib
, pkgs
, ...
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
      mcps = {
        mcpServers = {
          k8s = {
            # type = "stdio";
            command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
            args = [ ];
          };
        };
      };

      kubeMcpConfig = pkgs.writeTextFile {
        name = "kube-mcp-config.json";
        text = builtins.toJSON mcps;
      };

    in
    (lib.strings.join "," (
      lib.optional config.kubernetes kubeMcpConfig.outPath
    ));
}
