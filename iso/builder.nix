{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Ensure SSH starts automatically
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  image.fileName = "nixos-impermanence.iso";
  isoImage.squashfsCompression = "zstd";

  # Enable SSH daemon without password authentication
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PermitEmptyPasswords = true;
      PasswordAuthentication = true;
      ChallengeResponseAuthentication = false;
      UsePAM = false;
    };
  };

  # Set empty password for root user and disable password aging
  users.users.root = {
    hashedPassword = "";
    password = "";
  };

  # Disable password prompts in PAM
  security.pam.services.sshd.unixAuth = false;

  environment.systemPackages = with pkgs; [
    git
    curl
    neovim
    disko
  ];

  # Auto-install script included in ISO
  environment.etc."auto-install.sh".text = ''
    #!/bin/sh
    set -eux
    HOSTNAME="$1"
    REPO="https://github.com/kita99/dotfiles.git"

    # Clone dotfiles to temporary location first
    git clone "$REPO" /tmp/dotfiles

    # Run disko from temporary location
    disko --mode disko /tmp/dotfiles/hosts/"$HOSTNAME"/disko.nix

    # Wait for devices to be ready
    sleep 2

    # Mount the root btrfs filesystem
    mount /dev/disk/by-label/nixos /mnt

    # Create root-blank snapshot for impermanence
    btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

    # Mount boot partition (ESP)
    mkdir -p /mnt/boot
    mount /dev/disk/by-partlabel/ESP /mnt/boot

    # Setup LUKS encrypted partition for secure storage
    echo "Setting up encrypted secure partition..."
    echo "Please enter password for secure partition:"
    cryptsetup luksFormat /dev/disk/by-partlabel/secure
    echo "Please enter the same password to unlock:"
    cryptsetup open /dev/disk/by-partlabel/secure secure

    # Mount secure partition
    mkdir -p /mnt/secure
    mount /dev/mapper/secure /mnt/secure

    # Copy dotfiles to the mounted system
    cp -r /tmp/dotfiles /mnt/etc/nixos

    # Install NixOS from flake
    nixos-install --flake /mnt/etc/nixos#"$HOSTNAME" --no-root-passwd

    # Cleanup
    rm -rf /tmp/dotfiles
  '';
  environment.etc."auto-install.sh".mode = "0755";
}

