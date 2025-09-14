{ config, pkgs, lib, ... }: {
  # Disko will handle most filesystem configuration
  # We only need to specify neededForBoot for persistence filesystems
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/secure".neededForBoot = true;
  fileSystems."/secure/ssh".neededForBoot = true;
  fileSystems."/secure/secrets".neededForBoot = true;
}
