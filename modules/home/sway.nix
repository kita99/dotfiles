{ config, lib, pkgs, ... }:

let
  c = config.theme.colors;
  mod = "Mod4";
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    config = {
      modifier = mod;
      terminal = "kitty";
      menu = "rofi -modi run -show drun -show-icons";

      fonts = {
        names = [ config.theme.font ];
        size = 8.0;
      };

      gaps = {
        inner = 8;
        outer = 3;
        smartBorders = "on";
      };

      colors = {
        focused = {
          border = c.accent;
          background = c.accent;
          text = config.theme.palette.base3;
          indicator = c.indicator;
          childBorder = c.accent;
        };
        focusedInactive = {
          border = c.bgAlt;
          background = c.bgAlt;
          text = config.theme.palette.base2;
          indicator = c.indicator;
          childBorder = c.bgAlt;
        };
        unfocused = {
          border = c.bgAlt;
          background = c.bgAlt;
          text = c.fgAlt;
          indicator = c.dim;
          childBorder = c.bgAlt;
        };
        urgent = {
          border = c.urgent;
          background = c.urgent;
          text = config.theme.palette.base3;
          indicator = config.theme.palette.red;
          childBorder = c.urgent;
        };
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:escape";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
        };
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec kitty";
        "${mod}+Shift+Return" = "exec kitty --class floating";
        "${mod}+space" = "exec rofi -modi run -show drun -show-icons";
        "Mod1+Tab" = "exec rofi -show window";
        "${mod}+Shift+q" = "kill";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+c" = "split h";
        "${mod}+v" = "split v";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+a" = "focus parent";

        "${mod}+Shift+a" = "exec loginctl lock-session";

        "XF86MonBrightnessUp" = "exec brightnessctl s +1%";
        "XF86MonBrightnessDown" = "exec brightnessctl s 1%-";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +1%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -1%";
        "XF86AudioPlay" = "exec playerctl play-pause";

        "Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "Shift+Print" = "exec grim - | wl-copy";
      };

      bars = [ ];
    };

    extraConfig = ''
      exec swayidle -w \
        timeout 240 'swaylock -f' \
        timeout 300 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        before-sleep 'swaylock -f'

      for_window [app_id="floating"] floating enable
    '';
  };

  programs.swaylock.settings = {
    color = lib.removePrefix "#" c.bg;
    indicator-radius = 100;
    ring-color = lib.removePrefix "#" c.accent;
    key-hl-color = lib.removePrefix "#" config.theme.palette.green;
    text-color = lib.removePrefix "#" c.fg;
    show-failed-attempts = true;
  };

  services.mako = {
    enable = true;
    settings = {
      background-color = c.bgAlt;
      text-color = c.fg;
      border-color = c.accent;
      border-size = 2;
      border-radius = 4;
      font = "${config.theme.font} ${toString config.theme.fontSize}";
      default-timeout = 5000;
    };
  };
}
