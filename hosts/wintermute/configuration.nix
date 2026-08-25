{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/impermanence.nix
    ../../modules/nixos/vm-variant.nix
    ../../modules/nixos/impermanence-diff.nix
  ];

  networking.hostName = "wintermute";

  users.users.kita = {
    isNormalUser = true;
    description = "kita";
    home = "/home/kita";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "libvirtd" ];

    openssh.authorizedKeys.keys = import ../../lib/authorized-keys.nix;

    hashedPassword = "!";
  };

  users.users.root.hashedPassword = "!";

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
  virtualisation.libvirtd.enable = true;

  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };
  console.useXkbConfig = true;
}
