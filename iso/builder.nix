{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Enable flakes and other experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

    # Enable experimental features for this session
    export NIX_CONFIG="experimental-features = nix-command flakes"

    # Clone dotfiles to temporary location first
    git clone "$REPO" /tmp/dotfiles

    # Run disko from temporary location - this will partition and mount everything
    disko --mode disko /tmp/dotfiles/hosts/"$HOSTNAME"/disko.nix

    # Wait for devices to be ready
    sleep 2

    # Create root-blank snapshot for impermanence (disko already mounted at /mnt)
    btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

    # Setup LUKS encrypted partition for secure storage
    echo "Setting up encrypted secure partition..."
    echo "Please enter password for secure partition:"
    cryptsetup luksFormat /dev/disk/by-partlabel/secure
    echo "Please enter the same password to unlock:"
    cryptsetup open /dev/disk/by-partlabel/secure secure

    # Format the secure partition
    mkfs.btrfs -L secure /dev/mapper/secure

    # Mount secure partition temporarily to create subvolumes
    mkdir -p /mnt/secure
    mount /dev/mapper/secure /mnt/secure

    # Create subvolumes in secure partition
    btrfs subvolume create /mnt/secure/ssh
    btrfs subvolume create /mnt/secure/secrets

    # Unmount and create proper mount points
    umount /mnt/secure
    mkdir -p /mnt/secure/ssh
    mkdir -p /mnt/secure/secrets

    # Mount subvolumes to their proper locations
    mount -o subvol=ssh /dev/mapper/secure /mnt/secure/ssh
    mount -o subvol=secrets /dev/mapper/secure /mnt/secure/secrets

    # Copy dotfiles to the mounted system
    cp -r /tmp/dotfiles /mnt/etc/nixos

    # Install NixOS from flake
    nixos-install --flake /mnt/etc/nixos#"$HOSTNAME" --no-root-passwd

    # Cleanup
    rm -rf /tmp/dotfiles
  '';
  environment.etc."auto-install.sh".mode = "0755";
}

