{ pkgs
, diskoLib
, impermanence
, home-manager
}:

diskoLib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "wintermute-full-system";

  disko-config = import ../hosts/wintermute/disko-config.nix {
    device = "/dev/vda";
    luksKeyFile = "/tmp/secret.key";
    swapSize = "64M";
  };

  extraInstallerConfig = {
    virtualisation.memorySize = 4096;
    virtualisation.diskSize = 16384;
  };

  extraSystemConfig = {
    imports = [
      impermanence.nixosModules.impermanence
      home-manager.nixosModules.home-manager

      ../modules/nixos/common.nix
      ../modules/nixos/desktop.nix
      ../modules/nixos/impermanence.nix
      ../modules/nixos/impermanence-diff.nix
    ];

    networking.hostName = "wintermute";

    users.users.kita = {
      isNormalUser = true;
      home = "/home/kita";
      uid = 1000;
      extraGroups = [ "wheel" "video" "audio" ];
      initialPassword = "test";
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      users.kita = {
        imports = [ ../modules/home ];
        home.packages = pkgs.lib.mkForce (with pkgs; [
          pavucontrol
          fzf
          eza
          bat
        ]);
      };
    };

    services.xserver.xkb.options = "caps:escape";

    virtualisation.writableStore = true;

    services.tlp.enable = pkgs.lib.mkForce false;
    services.thermald.enable = pkgs.lib.mkForce false;
    services.fprintd.enable = pkgs.lib.mkForce false;
    hardware.cpu.intel.updateMicrocode = pkgs.lib.mkForce false;
  };

  extraTestScript = ''
    machine.wait_for_unit("multi-user.target")

    machine.wait_for_unit("home-manager-kita.service")
    machine.succeed("systemctl is-active home-manager-kita.service")
    machine.succeed("test -e /home/kita/.config/sway/config")
    machine.succeed("test -e /home/kita/.config/waybar/config")
    machine.succeed("test -e /home/kita/.config/kitty/kitty.conf")

    machine.succeed("grep -qs 'cb4b16' /home/kita/.config/sway/config")
    machine.succeed("grep -qs '002b36' /home/kita/.config/kitty/kitty.conf")
    machine.succeed("grep -qs 'Mod4' /home/kita/.config/sway/config")
    machine.succeed("grep -qs 'caps:escape' /home/kita/.config/sway/config")

    machine.succeed("systemctl is-active greetd.service || systemctl is-enabled greetd.service")
    machine.succeed("systemctl is-active dbus.service")
    machine.succeed("test -x /run/current-system/sw/bin/sway")
    machine.succeed("test -x /run/current-system/sw/bin/waybar")
    machine.succeed("test -x /run/current-system/sw/bin/rofi")
    machine.succeed("test -x /run/current-system/sw/bin/impermanence-diff")

    machine.succeed(
        "WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 XDG_RUNTIME_DIR=/run/user/0 "
        "timeout 20 sway -c /home/kita/.config/sway/config --validate"
    )

    machine.succeed("mountpoint -q /persist")
    machine.succeed("test -d /home/kita/Projects")

    machine.succeed("echo ephemeral > /marker-root")
    machine.succeed("echo durable > /persist/marker-persist")
    machine.succeed("mkdir -p /home/kita/Projects/keepme && echo yes > /home/kita/Projects/keepme/f")
    machine.succeed("echo lost > /home/kita/scratch-file")

    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.fail("test -e /marker-root")
    machine.succeed("test -e /persist/marker-persist")

    machine.succeed("test -e /home/kita/Projects/keepme/f")
    machine.fail("test -e /home/kita/scratch-file")

    machine.wait_for_unit("home-manager-kita.service")
    machine.succeed("test -e /home/kita/.config/sway/config")

    print("full system: boots, home-manager re-activates on a wiped home, impermanence holds")
  '';
}
