{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  image.fileName = "nixos-impermanence.iso";
  isoImage.squashfsCompression = "zstd";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PermitEmptyPasswords = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys =
    import ../lib/authorized-keys.nix;

  environment.systemPackages = with pkgs; [
    git
    curl
    neovim
    disko
  ];

  environment.etc."auto-install.sh".text = ''
    #!/bin/sh
    set -eux
    HOSTNAME="$1"

    export NIX_CONFIG="experimental-features = nix-command flakes"

    disko-install --write-efi-boot-entries --flake github:kita99/dotfiles#"$HOSTNAME" --disk main /dev/sda
  '';
  environment.etc."auto-install.sh".mode = "0755";
}
