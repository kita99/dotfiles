{ config, lib, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = lib.mkDefault "Europe/Lisbon";
  i18n.defaultLocale = "en_GB.UTF-8";

  users.mutableUsers = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  networking.wg-quick.interfaces.wg0.configFile = "/persist/wireguard/wg0.conf";

  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
    ripgrep
    fd
    jq
    tree
    htop
    btop
    unzip
    zip
    age
    rclone
    zstd
    wireguard-tools
    pciutils
    usbutils
    lm_sensors
  ];

  programs.zsh.enable = true;

  system.stateVersion = "25.05";
}
