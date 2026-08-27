{ config, lib, pkgs, ... }:

{
  imports = [
    ./configuration.nix

    (import ./disko-config.nix {
      device = "/dev/vdb";
      luksKeyFile = "/tmp/secret.key";
      swapSize = "512M";
    })
  ];

  boot.initrd.secrets."/tmp/secret.key" = pkgs.writeText "secret.key" "disko-install-test";
  boot.initrd.luks.devices.cryptroot.keyFile = "/tmp/secret.key";

  services.tlp.enable = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;
  services.fprintd.enable = lib.mkForce false;
  hardware.cpu.intel.updateMicrocode = lib.mkForce false;
  hardware.enableRedistributableFirmware = lib.mkForce false;

  users.users.root.hashedPassword = lib.mkForce "";
  users.users.kita.hashedPassword = lib.mkForce "";

  boot.kernelParams = [ "console=ttyS0" ];

  home-manager.users.kita.home.packages = lib.mkForce (with pkgs; [
    pavucontrol
    fzf
    eza
    bat
  ]);
}
