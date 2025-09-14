{ config, pkgs, lib, ... }:

{
  networking.hostName = "kita";

  users.users.kita = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/kita";
    password = ""; # set after install
  };

  services.openssh.enable = true;
  time.timeZone = "UTC";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.persistence = {
    "/persist" = {
      directories = [ "/etc/nixos" "/var/lib" ];
      files = [ "/etc/machine-id" ];
    };
    "/secure" = {
      users.kita = {
        directories = [ ".ssh" ".gnupg" ];
      };
    };
  };

  system.stateVersion = "24.05";
}
