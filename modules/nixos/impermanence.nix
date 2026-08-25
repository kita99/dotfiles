{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs root subvolume to a pristine state";
    wantedBy = [ "initrd.target" ];
    after = [ "systemd-cryptsetup@cryptroot.service" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail

      MNT=/btrfs_tmp
      mkdir -p "$MNT"
      mount -o subvol=/ /dev/mapper/cryptroot "$MNT"

      if [[ -e "$MNT/@root" ]]; then
        mkdir -p "$MNT/old_roots"
        timestamp=$(date --date="@$(stat -c %Y "$MNT/@root")" "+%Y-%m-%d_%H:%M:%S")
        mv "$MNT/@root" "$MNT/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "$MNT/$i"
        done
        btrfs subvolume delete "$1"
      }

      for i in $(find "$MNT/old_roots/" -maxdepth 1 -mtime +30 2>/dev/null); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume snapshot "$MNT/@root-blank" "$MNT/@root"
      umount "$MNT"
    '';
  };

  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      "/var/lib/iwd"
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    users.kita = {
      directories = [
        "work"

        "Projects"
        "Github"
        "Downloads"
        "Documents"
        "Music"
        "Images"
        "Videos"
        "Android"
        "Assets"
        "AUR"
        "backups"
        "dotfiles"
        "go"
        "Concepts"
        "ObsidianVaults"

        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".aws"; mode = "0700"; }
        { directory = ".kube"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        ".config/gh"
        ".config/rclone"
        ".pki"

        ".local/share/direnv"
        ".local/share/nvim"
        ".local/share/zsh"
        ".local/state/nvim"
        ".local/share/zed"
        ".mozilla"
        ".config/google-chrome"
        ".config/Code"
        ".claude"
        ".codex"
        ".cache/nix"
      ];

      files = [
        ".zsh_history"
        ".bash_history"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /persist/home/kita 0700 kita users -"
  ];

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
