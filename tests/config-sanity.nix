{ pkgs, config, lib }:

let
  solarized = import ../lib/solarized.nix;

  disk = config.disko.devices.disk.main;
  luks = disk.content.partitions.luks.content;
  rollback = config.boot.initrd.systemd.services.rollback;
  hm = config.home-manager.users.kita;
  persist = config.environment.persistence."/persist";

  checks = [
    {
      name = "no hardware serial committed to a public repo";
      ok = !(lib.hasPrefix "/dev/disk/by-id/" disk.device);
      detail = "device = ${disk.device}; pass the real disk via `disko-install --disk main <device>` instead";
    }
    {
      name = "boot resolves LUKS by partlabel, not by device node";
      ok =
        let d = config.boot.initrd.luks.devices.cryptroot.device;
        in lib.hasPrefix "/dev/disk/by-partlabel/" d || lib.hasPrefix "/dev/disk/by-uuid/" d;
      detail = "luks device = ${config.boot.initrd.luks.devices.cryptroot.device}";
    }
    {
      name = "rollback waits on the LUKS device disko actually creates";
      ok = builtins.elem "systemd-cryptsetup@${luks.name}.service" rollback.after;
      detail = "disko opens '${luks.name}'; rollback waits on ${toString rollback.after}";
    }
    {
      name = "rollback script references the same mapper name";
      ok = lib.hasInfix "/dev/mapper/${luks.name}" rollback.script;
      detail = "script must mount /dev/mapper/${luks.name}";
    }
    {
      name = "rollback ordered before the root filesystem is mounted";
      ok = builtins.elem "sysroot.mount" rollback.before;
      detail = "before = ${toString rollback.before}";
    }
    {
      name = "rollback is actually wanted by initrd";
      ok = builtins.elem "initrd.target" rollback.wantedBy;
      detail = "wantedBy = ${toString rollback.wantedBy}";
    }
    {
      name = "installer creates the @root-blank baseline";
      ok = lib.hasInfix "@root-blank" luks.content.postCreateHook;
      detail = "postCreateHook must snapshot @root to @root-blank, or first boot has nothing to restore";
    }
    {
      name = "@root-blank creation is idempotent";
      ok = lib.hasInfix "subvolume delete" luks.content.postCreateHook;
      detail = "a retried disko-install fails if the hook cannot overwrite an existing baseline";
    }
    {
      name = "/persist is mounted in the initrd";
      ok = config.fileSystems."/persist".neededForBoot;
      detail = "impermanence bind-mounts out of /persist before systemd starts";
    }
    {
      name = "every persisted subvolume exists in the disk layout";
      ok =
        let want = [ "@root" "@nix" "@persist" "@log" "@swap" ];
        in lib.all (s: builtins.hasAttr s luks.content.subvolumes) want;
      detail = "subvolumes = ${toString (builtins.attrNames luks.content.subvolumes)}";
    }
    {
      name = "user persistence paths are relative, not absolute";
      ok =
        let
          entries = persist.users.kita.directories or [ ];
          pathOf = e: if builtins.isString e then e else e.directory;
        in
        lib.all (e: !(lib.hasPrefix "/" (pathOf e))) entries;
      detail = "entries under users.kita.directories must not start with /";
    }
    {
      name = "swap is configured";
      ok = (luks.content.subvolumes."@swap".swap.swapfile.size or null) != null;
      detail = "no swapfile size set on @swap";
    }
    {
      name = "sway focused border matches the Solarized accent";
      ok = hm.wayland.windowManager.sway.config.colors.focused.border == solarized.dark.accent;
      detail = "sway=${hm.wayland.windowManager.sway.config.colors.focused.border} palette=${solarized.dark.accent}";
    }
    {
      name = "greeter launches sway";
      ok = lib.hasInfix "sway" config.services.greetd.settings.default_session.command;
      detail = config.services.greetd.settings.default_session.command;
    }
    {
      name = "caps:escape carried over from the i3 setup";
      ok = lib.hasInfix "caps:escape" (config.services.xserver.xkb.options or "");
      detail = "xkb options = ${config.services.xserver.xkb.options or "(unset)"}";
    }
  ];

  failed = builtins.filter (c: !c.ok) checks;

  report = lib.concatMapStringsSep "\n"
    (c: "${if c.ok then "  PASS" else "  FAIL"}  ${c.name}"
      + lib.optionalString (!c.ok) "\n        ${c.detail}")
    checks;
in
pkgs.runCommand "wintermute-config-sanity"
{
  passAsFile = [ "report" ];
  inherit report;
} ''
  cat "$reportPath"
  echo
  ${if failed == [ ] then ''
    echo "${toString (builtins.length checks)}/${toString (builtins.length checks)} checks passed"
    cp "$reportPath" $out
  '' else ''
    echo "${toString (builtins.length failed)} check(s) FAILED"
    exit 1
  ''}
''
