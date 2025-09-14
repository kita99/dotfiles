{
  disko.devices.disk0 = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512MiB";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0022" "dmask=0022" ];
          };
        };
        swap = {
          size = "8GiB";
          type = "8200";
          content = { type = "swap"; };
        };
        root = {
          size = "90%";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "nixos" ];
            mountpoint = "/";
            subvolumes = {
              root = { mountpoint = "/"; };
              nix = { mountpoint = "/nix"; };
              persist = { mountpoint = "/persist"; };
              log = { mountpoint = "/var/log"; };
              tmp = { mountpoint = "/tmp"; };
            };
          };
        };
        secure = {
          size = "10%";
          content = {
            type = "luks";
            name = "secure";
            content = {
              type = "btrfs";
              extraArgs = [ "-L" "secure" ];
              mountpoint = "/secure";
              subvolumes = {
                ssh = { mountpoint = "/secure/ssh"; };
                secrets = { mountpoint = "/secure/secrets"; };
              };
            };
          };
        };
      };
    };
  };
}
