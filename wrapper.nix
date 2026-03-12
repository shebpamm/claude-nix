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
    nixos = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nixos tools";
    };
  };

  config =
    {
      package = pkgs.claude-code;

      flags."--mcp-config" =
        let
          mcps = {
            mcpServers = {
              k8s = {
                command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
                args = [ "--readonly" ];
              };
              nixos = {
                command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
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
    };
}
