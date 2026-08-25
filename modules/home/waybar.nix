{ config, lib, pkgs, ... }:

let
  c = config.theme.colors;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 8;

      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "pulseaudio"
        "backlight"
        "network"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "clock"
        "tray"
      ];

      "sway/workspaces" = {
        disable-scroll = true;
        format = "{name}";
      };

      "sway/window" = {
        max-length = 60;
        tooltip = false;
      };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      cpu.format = "cpu {usage}%";
      memory.format = "mem {percentage}%";
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C";
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "bat {capacity}%";
        format-charging = "chg {capacity}%";
        format-plugged = "ac {capacity}%";
      };

      network = {
        format-wifi = "{essid} {signalStrength}%";
        format-ethernet = "eth";
        format-disconnected = "offline";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      pulseaudio = {
        format = "vol {volume}%";
        format-muted = "muted";
        on-click = "pavucontrol";
      };

      backlight = {
        format = "bri {percent}%";
        on-scroll-up = "brightnessctl s +1%";
        on-scroll-down = "brightnessctl s 1%-";
      };

      tray.spacing = 8;
    };

    style = ''
      * {
        font-family: "${config.theme.font}";
        font-size: ${toString config.theme.fontSize}pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: ${c.bg};
        color: ${c.fg};
        border-bottom: 2px solid ${c.bgAlt};
      }

      #workspaces button {
        padding: 0 10px;
        background-color: transparent;
        color: ${c.dim};
      }

      #workspaces button.focused,
      #workspaces button.visible {
        color: ${config.theme.palette.base3};
        background-color: ${c.accent};
      }

      #workspaces button.urgent {
        background-color: ${c.urgent};
        color: ${config.theme.palette.base3};
      }

      #mode {
        background-color: ${c.accent};
        color: ${config.theme.palette.base3};
        padding: 0 10px;
      }

      #window { color: ${c.fgAlt}; }

      #pulseaudio, #backlight, #network, #cpu, #memory,
      #temperature, #battery, #clock, #tray {
        padding: 0 10px;
        color: ${c.fg};
      }

      #clock { color: ${config.theme.palette.base1}; }

      #battery.warning  { color: ${config.theme.palette.yellow}; }
      #battery.critical { color: ${config.theme.palette.red}; }
      #temperature.critical { color: ${config.theme.palette.red}; }
      #network.disconnected { color: ${config.theme.palette.red}; }
    '';
  };
}
