{ config, lib, pkgs, ... }:

{
  imports = [
    ./theme.nix
    ./sway.nix
    ./waybar.nix
    ./terminal.nix
  ];

  home.username = "kita";
  home.homeDirectory = "/home/kita";
  home.stateVersion = "25.05";

  theme.variant = "dark";

  home.packages = with pkgs; [
    firefox
    google-chrome
    pavucontrol
    imv
    mpv
    zathura
    file
    dust
    bat
    eza
    fzf
    gh
    just
  ];

  programs.home-manager.enable = true;

  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    createDirectories = true;
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Images";
    videos = "${config.home.homeDirectory}/Videos";
  };
}
