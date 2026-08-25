{ pkgs
, home-manager
}:

pkgs.testers.runNixOSTest {
  name = "wintermute-home-activation";

  nodes.machine = { config, lib, ... }: {
    imports = [ home-manager.nixosModules.home-manager ];

    virtualisation.writableStore = true;
    virtualisation.memorySize = 2048;

    fileSystems."/home" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=0755" ];
    };

    users.users.kita = {
      isNormalUser = true;
      home = "/home/kita";
      uid = 1000;
      initialPassword = "test";
    };

    programs.zsh.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      users.kita = {
        imports = [ ../modules/home ];
        home.packages = lib.mkForce [ ];
      };
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    machine.wait_for_unit("home-manager-kita.service")
    machine.succeed("systemctl is-active home-manager-kita.service")
    machine.succeed("test -L /home/kita/.config/sway/config")
    machine.succeed("test -e /home/kita/.config/waybar/config")
    machine.succeed("test -e /home/kita/.config/kitty/kitty.conf")

    machine.succeed("grep -qs 'cb4b16' /home/kita/.config/sway/config")
    machine.succeed("grep -qs '002b36' /home/kita/.config/kitty/kitty.conf")
    machine.succeed("grep -qs 'Mod4' /home/kita/.config/sway/config")

    gen_before = machine.succeed(
        "readlink -f /nix/var/nix/profiles/per-user/kita/home-manager || true"
    ).strip()
    print(f"generation after first boot: {gen_before}")

    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("test -z \"$(ls -A /home/kita 2>/dev/null || true)\" || true")

    machine.wait_for_unit("home-manager-kita.service")
    machine.succeed("systemctl is-active home-manager-kita.service")
    machine.succeed("test -L /home/kita/.config/sway/config")
    machine.succeed("test -e /home/kita/.config/waybar/config")
    machine.succeed("test -e /home/kita/.config/kitty/kitty.conf")
    machine.succeed("grep -qs 'cb4b16' /home/kita/.config/sway/config")

    machine.succeed("test -e /home/kita/.zshrc || test -L /home/kita/.zshrc")

    print("home-manager re-links a wiped $HOME on every boot")
  '';
}
