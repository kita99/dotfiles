{ config, pkgs, lib, ... }:

{
  networking.hostName = "wintermute";

  users.mutableUsers = false;

  users.users.kita = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTM2+UKKWOSpaP0tW2+Aq/KLtn2tYjkQWLMUVZoltB8AV3KMder8y2cBDMqIhQ2pQopgqjYV71AKJgrBRgtq1Kc2ypTIlc2dXdZiSa3S06hdRd0ln2AQpMofNDO/ZfpnErjM/p1/DknuDPXc50hXMafdyHDob/oQhvTIPysIXqSRinZPM1DY4GFZfrZYcqd8Iep9v0NLJiULBiODJd89+mMGcvjNDTXB+9BLx5VlWW4myGfacWxFTj+HEezI3EVRevBlWeMIflLs0EriTmYz28b5+rODpGXlaXW4H0Fj90g0k9OwgbIeuZvANcG4GidP6IueJDcQExlRh0betmlH7mJYpV86pazhAIzq5W7xNhTaOPoAkOBmBmQRfH/WuKhO6rILZ4HqkUzSkyLmIYYyweQ5YCz6y+6lAA6iSxmVfLStGHQv3wvPxhUtLM63IgfsJojO+2fPW8Igj9dGgwvVyzF3/bSRDxhDACIs0F81Mb2jkORgMQmu7vnZRRPAGfTKU="
    ];
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/kita";
    initialPassword = "changeme";
  };

  services.openssh.enable = true;
  time.timeZone = "UTC";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.persistence = {
    "/persist" = {
      directories = [ "/etc/nixos" "/var/lib" ];
      files = [ "/etc/machine-id" ];
    };
    "/secure" = {
      users.kita = {
        directories = [ ".ssh" ".gnupg" ];
      };
    };
  };

  system.stateVersion = "25.05";
}
