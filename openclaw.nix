  { config, pkgs, lib, ... }:

  let
    openclawUser = "hangsai";
  in
  {
    environment.systemPackages = with pkgs; [
      nodejs_22
    ];

    # Keep user services running after logout.
    users.users.${openclawUser}.linger = true;

    systemd.user.services.openclaw-gateway = {
      description = "OpenClaw Gateway";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "%h/.local/bin/openclaw gateway";
        Restart = "always";
        RestartSec = 10;
        Environment = [
          "PATH=/run/current-system/sw/bin:%h/.local/bin"
          "OPENAI_API_BASE=http://127.0.0.1:8000/v1"
          "OPENAI_API_KEY=local"
        ];
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ReadWritePaths = "%h";
      };
    };
  }
