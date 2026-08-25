{ config, lib, pkgs, ... }:

{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
      diskSize = 16384;
      graphics = true;
      qemu.options = [
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };

    boot.initrd.systemd.services.rollback.wantedBy = lib.mkForce [ ];

    fileSystems."/persist" = lib.mkForce {
      device = "/dev/disk/by-label/persist-vm";
      fsType = "ext4";
      neededForBoot = true;
      autoFormat = true;
    };

    virtualisation.emptyDiskImages = [ 2048 ];

    users.users.kita.hashedPassword = lib.mkForce "";
    users.users.kita.initialPassword = lib.mkForce "vm";

    services.greetd.settings.default_session = lib.mkForce {
      command = "${pkgs.sway}/bin/sway";
      user = "kita";
    };
  };
}
