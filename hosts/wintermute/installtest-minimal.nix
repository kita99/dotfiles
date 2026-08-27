{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/testing/test-instrumentation.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ./hardware.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/impermanence.nix
    (import ./disko-config.nix {
      device = "/dev/vdb";
      luksKeyFile = "/tmp/secret.key";
      swapSize = "512M";
    })
  ];

  networking.hostName = "wintermute";

  boot.initrd.secrets."/tmp/secret.key" = pkgs.writeText "secret.key" "disko-install-test";
  boot.initrd.luks.devices.cryptroot.keyFile = "/tmp/secret.key";

  users.users.kita = {
    isNormalUser = true;
    home = "/home/kita";
    uid = 1000;
    initialPassword = "test";
  };
  users.users.root.hashedPassword = lib.mkForce "";

  services.tlp.enable = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;
  hardware.cpu.intel.updateMicrocode = lib.mkForce false;
  hardware.enableRedistributableFirmware = lib.mkForce false;

  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200" ];

  users.users.root.initialHashedPassword = lib.mkForce "";
}
