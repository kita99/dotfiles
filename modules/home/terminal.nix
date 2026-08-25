{ config, lib, pkgs, ... }:

let
  c = config.theme.colors;
  p = config.theme.palette;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = config.theme.font;
      size = config.theme.fontSize;
    };
    settings = {
      background = c.bg;
      foreground = c.fg;
      selection_background = c.bgAlt;
      selection_foreground = p.base3;
      cursor = c.accent;
      cursor_blink_interval = "0.15";
      cursor_stop_blinking_after = 0;
      url_color = p.blue;

      color0 = p.base02;
      color8 = p.base03;
      color1 = p.red;
      color9 = p.orange;
      color2 = p.green;
      color10 = p.base01;
      color3 = p.yellow;
      color11 = p.base00;
      color4 = p.blue;
      color12 = p.base0;
      color5 = p.magenta;
      color13 = p.violet;
      color6 = p.cyan;
      color14 = p.base1;
      color7 = p.base2;
      color15 = p.base3;

      enable_audio_bell = false;
      window_padding_width = 4;
      confirm_os_window_close = 0;
    };
  };

  programs.rofi = {
    enable = true;
    font = "${config.theme.font} ${toString config.theme.fontSize}";
    terminal = "${pkgs.kitty}/bin/kitty";
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          background = mkLiteral c.bg;
          background-alt = mkLiteral c.bgAlt;
          foreground = mkLiteral c.fg;
          selected = mkLiteral c.accent;
          urgent = mkLiteral c.urgent;
        };

        "window" = {
          transparency = "real";
          border-radius = mkLiteral "6px";
          border = mkLiteral "2px";
          border-color = mkLiteral c.accent;
          width = mkLiteral "40%";
          background-color = mkLiteral "@background";
        };

        "mainbox".children = map mkLiteral [ "inputbar" "listview" ];

        "inputbar" = {
          padding = mkLiteral "8px";
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "@foreground";
          children = map mkLiteral [ "prompt" "entry" ];
        };

        "prompt" = {
          background-color = mkLiteral "@selected";
          text-color = mkLiteral p.base3;
          padding = mkLiteral "4px 8px";
          border-radius = mkLiteral "4px";
        };

        "entry" = {
          padding = mkLiteral "4px 8px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
          placeholder = "search";
        };

        "listview" = {
          lines = 10;
          padding = mkLiteral "8px";
          background-color = mkLiteral "@background";
        };

        "element" = {
          padding = mkLiteral "6px";
          border-radius = mkLiteral "4px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
        };

        "element selected" = {
          background-color = mkLiteral "@selected";
          text-color = mkLiteral p.base3;
        };

        "element-icon" = {
          size = mkLiteral "1.2em";
          padding = mkLiteral "0 6px 0 0";
        };
      };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      ll = "ls -alh";
      gs = "git status";
      rebuild = "sudo nixos-rebuild switch --flake ~/Github/dotfiles#wintermute";
    };
  };

  programs.zsh.plugins = [
    {
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
