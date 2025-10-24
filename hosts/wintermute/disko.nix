{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0022" "dmask=0022" ];
          };
        };
        swap = {
          size = "8G";
          type = "8200";
          content = { type = "swap"; };
        };
        secure = {
          size = "3G";
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
        root = {
          size = "100%";
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
      };
    };
  };
}
