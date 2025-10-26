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

    # Enable experimental features for this session
    export NIX_CONFIG="experimental-features = nix-command flakes"

    # Install NixOS from flake
    disko-install --write-efi-boot-entries --flake github:kita99/dotfiles#"$HOSTNAME" --disk main /dev/sda
  '';
  environment.etc."auto-install.sh".mode = "0755";
}
