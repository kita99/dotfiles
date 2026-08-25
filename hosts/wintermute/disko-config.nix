{ device ? "/dev/nvme0n1"
, luksKeyFile ? null
, swapSize ? "16G"
, ...
}:

{
  disko.devices.disk.main = {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings = {
              allowDiscards = true;
            } // (if luksKeyFile != null then { keyFile = luksKeyFile; } else { });

            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nixos" "-f" ];

              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "@swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "noatime" ];
                  swap.swapfile.size = swapSize;
                };
              };

              postCreateHook = ''
                MNTPOINT=$(mktemp -d)
                mount -o subvol=/ "/dev/mapper/cryptroot" "$MNTPOINT"
                trap 'umount "$MNTPOINT"; rmdir "$MNTPOINT"' EXIT
                if btrfs subvolume show "$MNTPOINT/@root-blank" >/dev/null 2>&1; then
                  btrfs subvolume delete "$MNTPOINT/@root-blank"
                fi
                btrfs subvolume snapshot -r "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
              '';
            };
          };
        };
      };
    };
  };
}
