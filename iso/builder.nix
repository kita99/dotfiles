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
    age
    age-plugin-yubikey
    wireguard-tools
    yubikey-manager
  ];

  services.pcscd.enable = true;

  environment.etc."migration/identity.yk.age".source = ../secrets/identity.yk.age;
  environment.etc."migration/wg0.conf.yk.age".source = ../secrets/wg0.conf.yk.age;
  environment.etc."migration/nm-connections.tar.yk.age".source =
    ../secrets/nm-connections.tar.yk.age;

  environment.etc."migration/unlock.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      set -eu
      out=''${1:-/tmp}

      age-plugin-yubikey --identity > "$out/yk-stub.txt"
      grep -q AGE-PLUGIN-YUBIKEY "$out/yk-stub.txt" || {
        echo "no YubiKey identity found - is it inserted, and is pcscd up?" >&2
        exit 1
      }

      age -d -i "$out/yk-stub.txt" -o "$out/identity.txt"       /etc/migration/identity.yk.age
      chmod 600 "$out/identity.txt"
      age -d -i "$out/yk-stub.txt" -o "$out/wg0.conf"           /etc/migration/wg0.conf.yk.age
      age -d -i "$out/yk-stub.txt" -o "$out/nm-connections.tar" /etc/migration/nm-connections.tar.yk.age
      echo "unlocked into $out"
    '';
  };

  environment.etc."auto-install.sh".text = ''
    #!/bin/sh
    set -eux
    HOSTNAME="$1"

    export NIX_CONFIG="experimental-features = nix-command flakes"

    disko-install --write-efi-boot-entries --flake github:kita99/dotfiles#"$HOSTNAME" --disk main /dev/sda
  '';
  environment.etc."auto-install.sh".mode = "0755";
}
