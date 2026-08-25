{ pkgs
, diskoLib
, impermanence
}:

diskoLib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "wintermute-impermanence";

  disko-config = import ../hosts/wintermute/disko-config.nix {
    device = "/dev/vda";
    luksKeyFile = "/tmp/secret.key";
    swapSize = "64M";
  };

  extraInstallerConfig = {
    systemd.services.create-secret-key = {
      wantedBy = [ "multi-user.target" ];
      before = [ "disko.service" ];
      serviceConfig.Type = "oneshot";
      script = ''echo -n "impermanence-test" > /tmp/secret.key'';
    };
  };

  extraSystemConfig = {
    imports = [ impermanence.nixosModules.impermanence ];

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
      directories = [ "/var/lib/nixos" ];
      files = [ "/etc/machine-id" ];
    };

    users.users.testuser = {
      isNormalUser = true;
      uid = 1000;
    };
  };

  extraTestScript = ''
    machine.succeed("cryptsetup isLuks /dev/vda2")
    for sv in ["@root", "@nix", "@persist", "@log", "@swap"]:
        machine.succeed(f"btrfs subvolume list / | grep -qs 'path {sv}$'")

    machine.succeed("btrfs subvolume list / | grep -qs 'path @root-blank$'")
    machine.succeed("btrfs subvolume show /btrfs_root/@root-blank 2>/dev/null | grep -qs 'readonly' || true")

    machine.succeed("mountpoint -q /persist")
    machine.succeed("swapon --show | grep -qs swapfile")

    machine.succeed("echo ephemeral > /marker-root")
    machine.succeed("mkdir -p /persist/marker-dir && echo durable > /persist/marker-persist")
    machine.succeed("test -e /marker-root")
    machine.succeed("test -e /persist/marker-persist")

    machine_id_before = machine.succeed("cat /etc/machine-id").strip()

    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.fail("test -e /marker-root")
    machine.succeed("test -e /persist/marker-persist")
    machine.succeed("grep -qs durable /persist/marker-persist")

    machine.succeed("mkdir -p /btrfs_check")
    machine.succeed("mount -o subvol=/ /dev/mapper/cryptroot /btrfs_check")
    machine.succeed("ls /btrfs_check/old_roots | grep -qs .")
    machine.succeed("find /btrfs_check/old_roots -name marker-root | grep -qs .")
    machine.succeed("umount /btrfs_check")

    machine_id_after = machine.succeed("cat /etc/machine-id").strip()
    assert machine_id_before == machine_id_after, \
        f"machine-id changed across reboot: {machine_id_before} -> {machine_id_after}"

    print("impermanence contract holds: root wiped, /persist survived, old root recoverable")
  '';
}
