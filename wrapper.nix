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
    kubernetes.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kubernetes tools";
    };
    nixos.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nixos tools";
    };
    github.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable github tools";
    };
    grafana = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable grafana tools";
      };

      url = lib.mkOption {
        type = lib.types.str;
        description = "URL to a grafana instance to use for the grafana mcp server";
      };

      serviceAccountTokenPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to a kubernetes service account token to use for the grafana mcp server";
      };

      cloudflareAccess = {
        clientIdPath = lib.mkOption {
          type = lib.types.path;
          description = "Path to a file containing the Cloudflare Access Client ID";
        };

        clientSecretPath = lib.mkOption {
          type = lib.types.path;
          description = "Path to a file containing the Cloudflare Access Client Secret";
        };
      };
    };
  };

  config =
    let
      grafanaWrapper = pkgs.writeShellScript "mcp-grafana-wrapper" ''
        export GRAFANA_URL="${config.grafana.url}"
        export GRAFANA_SERVICE_ACCOUNT_TOKEN=$(cat "${config.grafana.serviceAccountTokenPath}")
        CF_CLIENT_ID=$(cat "${config.grafana.cloudflareAccess.clientIdPath}")
        CF_CLIENT_SECRET=$(cat "${config.grafana.cloudflareAccess.clientSecretPath}")
        export GRAFANA_EXTRA_HEADERS="{\"CF-Access-Client-Id\": \"$CF_CLIENT_ID\", \"CF-Access-Client-Secret\": \"$CF_CLIENT_SECRET\"}"
        exec ${pkgs.mcp-grafana}/bin/mcp-grafana "$@"
      '';

      githubWrapper = pkgs.writeShellScript "mcp-github-wrapper" ''
        export GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs.gh}/bin/gh auth token)"
        exec ${pkgs.github-mcp-server}/bin/github-mcp-server --read-only stdio "$@"
      '';
    in
    {
      package = pkgs.claude-code;

      flags."--mcp-config" =
        let
          mcpServers =
            lib.optionalAttrs config.kubernetes.enable {
              k8s = {
                command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
                args = [ "--readonly" ];
              };
            }
            // lib.optionalAttrs config.nixos.enable {
              nixos = {
                command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
                args = [ ];
              };
            }
            // lib.optionalAttrs config.grafana.enable {
              grafana = {
                command = "${grafanaWrapper}";
              };
            }

            // lib.optionalAttrs config.github.enable {
              github = {
                command = "${githubWrapper}";
              };
            };

          mcpConfig = pkgs.writeTextFile {
            name = "mcp-config.json";
            text = builtins.toJSON { mcpServers = mcpServers; };
          };

        in
        lib.mkIf (mcpServers != { }) mcpConfig.outPath;
    };
}
