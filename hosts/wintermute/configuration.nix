{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "wintermute";

  users.mutableUsers = true;

  users.users.root.initialHashedPassword = "";

  users.users.kita = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTM2+UKKWOSpaP0tW2+Aq/KLtn2tYjkQWLMUVZoltB8AV3KMder8y2cBDMqIhQ2pQopgqjYV71AKJgrBRgtq1Kc2ypTIlc2dXdZiSa3S06hdRd0ln2AQpMofNDO/ZfpnErjM/p1/DknuDPXc50hXMafdyHDob/oQhvTIPysIXqSRinZPM1DY4GFZfrZYcqd8Iep9v0NLJiULBiODJd89+mMGcvjNDTXB+9BLx5VlWW4myGfacWxFTj+HEezI3EVRevBlWeMIflLs0EriTmYz28b5+rODpGXlaXW4H0Fj90g0k9OwgbIeuZvANcG4GidP6IueJDcQExlRh0betmlH7mJYpV86pazhAIzq5W7xNhTaOPoAkOBmBmQRfH/WuKhO6rILZ4HqkUzSkyLmIYYyweQ5YCz6y+6lAA6iSxmVfLStGHQv3wvPxhUtLM63IgfsJojO+2fPW8Igj9dGgwvVyzF3/bSRDxhDACIs0F81Mb2jkORgMQmu7vnZRRPAGfTKU="
    ];
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/kita";
    initialPassword = "changeme";
  };

  services.openssh.enable = true;
  time.timeZone = "UTC";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable systemd in initrd for better handling of mount dependencies
  boot.initrd.systemd.enable = true;

  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_blk" "ehci_pci" "nvme" "sd_mod" "sr_mod" "ata_piix" "uhci_hcd" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  
  # Ensure these filesystems are available early in boot
  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/nixos";
  #     fsType = "btrfs";
  #     options = [ "subvol=root" "compress=zstd" ];
  #   };
  #   "/nix" = {
  #     device = "/dev/disk/by-label/nixos";
  #     fsType = "btrfs";
  #     options = [ "subvol=nix" "compress=zstd" ];
  #   };
  #   "/persist" = {
  #     device = "/dev/disk/by-label/nixos";
  #     fsType = "btrfs";
  #     options = [ "subvol=persist" "compress=zstd" ];
  #   };
  #   "/var/log" = {
  #     device = "/dev/disk/by-label/nixos";
  #     fsType = "btrfs";
  #     options = [ "subvol=log" "compress=zstd" ];
  #   };
  #   "/tmp" = {
  #     device = "/dev/disk/by-label/nixos";
  #     fsType = "btrfs";
  #     options = [ "subvol=tmp" "compress=zstd" ];
  #   };
  # };

  # Enable linux-firmware for hardware support
  hardware.enableRedistributableFirmware = true;

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

  system.stateVersion = "25.11";
}
