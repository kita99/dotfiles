{ config, lib, pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      swaybg
      wl-clipboard
      wf-recorder
      grim
      slurp
      mako
      brightnessctl
      playerctl
      wdisplays
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd sway";
        user = "greeter";
      };
    };
  };

  environment.persistence."/persist".directories = [ "/var/cache/tuigreet" ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "wlr" "gtk" ];
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.geoclue2.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
    ];
    fontconfig.defaultFonts = {
      monospace = [ "Iosevka Term Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      libva-vdpau-driver
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
}
