{ config, lib, pkgs, ... }:

let
  solarized = import ../../lib/solarized.nix;
in
{
  options.theme = {
    variant = lib.mkOption {
      type = lib.types.enum [ "dark" "light" ];
      default = "dark";
      description = "Which Solarized variant the static configs are built for.";
    };

    colors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      description = "Role-based colours for the selected variant.";
    };

    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      description = "The full 16-colour Solarized palette.";
    };

    font = lib.mkOption {
      type = lib.types.str;
      default = "Iosevka Term Nerd Font Mono";
      description = "Monospace font, matching the old i3/kitty configuration.";
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 10;
    };
  };

  config = {
    theme = {
      colors = solarized.${config.theme.variant};
      palette = solarized.palette;
    };

    services.darkman = {
      enable = true;
      settings.usegeoclue = true;

      darkModeScripts.gtk = ''
        ${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface color-scheme prefer-dark
      '';
      lightModeScripts.gtk = ''
        ${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface color-scheme prefer-light
      '';
    };
  };
}
