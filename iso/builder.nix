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

    # Create necessary directory structure
    mkdir -p /mnt/etc/nixos

    # Copy dotfiles to the mounted system
    cp -r /tmp/dotfiles /mnt/etc/nixos

    # Generate hardware-configuration.nix from current hardware
    nixos-generate-config --root /mnt --no-filesystems

    # Install NixOS from flake
    nixos-install --flake "$REPO"#"$HOSTNAME" --no-root-passwd

    # Cleanup
    rm -rf /tmp/dotfiles
  '';
  environment.etc."auto-install.sh".mode = "0755";
}
