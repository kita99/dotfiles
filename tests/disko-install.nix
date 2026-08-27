{ pkgs
, self
, disko
}:

let
  cfg = self.nixosConfigurations.wintermute-installtest-minimal;

  dependencies = [
    cfg.pkgs.stdenv.drvPath
    (cfg.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
    cfg.pkgs.perlPackages.ConfigIniFiles
    cfg.pkgs.perlPackages.FileSlurp
    cfg.config.system.build.toplevel
    cfg.config.system.build.toplevel.drvPath
    cfg.config.system.build.diskoScript
  ] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

in
pkgs.testers.nixosTest {
  name = "wintermute-disko-install";

  nodes.machine = {
    virtualisation.emptyDiskImages = [ 20480 ];
    virtualisation.memorySize = 4096;
    virtualisation.cores = 4;

    virtualisation.additionalPaths = dependencies;

    virtualisation.writableStore = true;

    environment.systemPackages = [
      disko.packages.${pkgs.system}.disko-install
      pkgs.cryptsetup
      pkgs.btrfs-progs
    ];
  };

  testScript = ''
    def boot_installed(oldmachine, **kwargs):
        start_command = [
            "${pkgs.qemu_test}/bin/qemu-kvm",
            "-cpu", "max",
            "-m", "3072",
            "-drive",
            "if=pflash,format=raw,unit=0,readonly=on,"
            "file=${pkgs.OVMF.firmware}",
            "-drive",
            f"if=pflash,format=raw,unit=1,file={oldmachine.state_dir}/efivars.fd",
            "-virtfs",
            "local,path=/nix/store,security_model=none,mount_tag=nix-store",
            "-drive",
            f"file={oldmachine.state_dir}/empty0.qcow2,id=drive1,if=none,index=1,werror=report",
            "-device", "virtio-blk-pci,drive=drive1",
        ]
        m = create_machine(start_command=" ".join(start_command), **kwargs)
        driver.machines_qemu.append(m)
        return m

    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("mkdir -p /tmp/efi")
    import shutil, os
    shutil.copyfile(
        "${pkgs.OVMF.variables}",
        os.path.join(machine.state_dir, "efivars.fd"),
    )
    os.chmod(os.path.join(machine.state_dir, "efivars.fd"), 0o644)

    machine.succeed("lsblk >&2")

    machine.succeed("umask 077; printf '%s' disko-install-test > /tmp/secret.key")
    machine.succeed("test -s /tmp/secret.key")

    machine.succeed(
        "disko-install --flake ${self}#wintermute-installtest-minimal "
        "--disk main /dev/vdb >&2"
    )

    machine.succeed("cryptsetup isLuks /dev/vdb2")

    machine.succeed(
        "test -e /dev/mapper/cryptroot || "
        "(echo -n disko-install-test | cryptsetup open /dev/vdb2 cryptroot -)"
    )
    machine.succeed("mkdir -p /mnt/check")
    machine.succeed("mount -o subvol=/ /dev/mapper/cryptroot /mnt/check")

    for sv in ["@root", "@nix", "@persist", "@log", "@swap"]:
        machine.succeed(f"btrfs subvolume list /mnt/check | grep -qs 'path {sv}$'")
    machine.succeed("btrfs subvolume list /mnt/check | grep -qs 'path @root-blank$'")
    machine.succeed("umount /mnt/check")

    machine.shutdown()

    installed = boot_installed(oldmachine=machine, name="installed")
    installed.start()
    installed.wait_for_unit("multi-user.target")

    hostname = installed.succeed("hostname").strip()
    assert hostname == "wintermute", f"expected hostname 'wintermute', got {hostname}"

    installed.succeed("mountpoint -q /persist")

    installed.succeed("echo ephemeral > /marker-root")
    installed.succeed("echo durable > /persist/marker-persist")
    installed.shutdown()
    installed.start()
    installed.wait_for_unit("multi-user.target")
    installed.fail("test -e /marker-root")
    installed.succeed("test -e /persist/marker-persist")

    print("disko-install produced a bootable, impermanent wintermute")
  '';
}
