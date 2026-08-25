# wintermute — NixOS, impermanent, encrypted

Declarative laptop config. Root is wiped on every boot and restored from a
pristine btrfs snapshot; only what is explicitly declared survives.

    LUKS2 → btrfs
      @root     /          rolled back every boot from @root-blank
      @nix      /nix       the store
      @persist  /persist   the only durable state
      @log      /var/log   kept out of @root so a bad boot is debuggable
      @swap     /swap      16 GiB swapfile (nodatacow)

Wayland throughout: **sway** (i3 replacement), **waybar** (polybar replacement),
**rofi**, **kitty**, **mako**, **greetd + tuigreet**. Solarized everywhere, from
a single palette in `lib/solarized.nix`.

## Layout

```
flake.nix                     nixpkgs-unstable, disko, impermanence, home-manager
lib/solarized.nix             the palette - one definition, every app derives from it
hosts/wintermute/
  disko.nix                   partitioning + the @root-blank baseline snapshot
  hardware.nix                i7-1165G7 / Iris Xe / NVMe
  configuration.nix           users, docker, libvirt, keyboard
modules/nixos/
  common.nix                  nix settings, gc, ssh, networking, base packages
  desktop.nix                 sway, greetd, pipewire, portals, fonts, graphics
  impermanence.nix            the rollback service + every persistence rule
modules/home/
  theme.nix                   exposes config.theme.{colors,palette,font}
  sway.nix                    i3 keybinds ported, Solarized borders
  waybar.nix                  bar + CSS derived from the palette
  terminal.nix                kitty, rofi, zsh/p10k, direnv, git
iso/builder.nix               installer ISO that runs disko-install
```

## Installing

The installer pulls the flake **from GitHub**, so push before you install —
an unpushed commit means installing the previous configuration.

```bash
# 1. generate your password hash - NOT committed, see below
mkpasswd -m yescrypt > /tmp/kita.hash

# 2. build and write the installer
nix build .#iso
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync

# 3. boot it, then:
# find your disk first - the by-id path embeds model+serial, which is why it
# is not committed to this public repo
ls -l /dev/disk/by-id/nvme-*

disko-install --write-efi-boot-entries \
  --flake github:kita99/dotfiles#wintermute \
  --disk main /dev/disk/by-id/nvme-<model>_<serial> \
  --extra-files /tmp/kita.hash /persist/passwd/kita
```

The installer needs plain internet for the flake fetch (`nmcli device wifi
connect <ssid> --ask`) — the WireGuard tunnel is not involved and is set up
after the first boot.

`disko-install` partitions, formats, takes the `@root-blank` snapshot, and
installs in one pass. The rollback baseline is created by the installer, so
there is no manual post-install step to forget.

Rebuild afterwards with `rebuild` (aliased in zsh) or:

```bash
sudo nixos-rebuild switch --flake ~/Github/dotfiles#wintermute
```

## Before first install

- **The password hash is not in this repo.** `hashedPasswordFile` points at
  `/persist/passwd/kita`, placed at install time by `--extra-files` (above).
  A public crypt hash is an offline target with no rate limiting and unlimited
  attempts — salt stops precomputed rainbow tables, but nothing stops a
  dictionary attack on one known hash. Use `-m yescrypt`: it is memory-hard,
  unlike `$6$` sha512crypt at its default 5000 rounds.
  If the file is missing the account has no password, so it fails closed.
- **WireGuard is not declared.** The tunnel key is secret and anything in the
  Nix store is world-readable. Put the config in `/persist` and reference it by
  path, or use agenix or sops-nix.
- **Neovim config is not migrated yet.** `.local/share/nvim` and
  `.local/state/nvim` are persisted, so the existing setup survives a restore,
  but it is not declarative.

## What persists

Everything else is gone at reboot. The list lives in
`modules/nixos/impermanence.nix`.

Work lives under a single generic `~/work`, so the persistence list names one
parent rather than every directory beneath it.

If you forget to persist something, it is not immediately lost: the outgoing
root is moved to `/btrfs_tmp/old_roots/<timestamp>` and kept for 30 days. Mount
the top-level subvolume to dig it out.

```bash
sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt
ls /mnt/old_roots/
```

That safety net matters more here than on most impermanent setups, because
`$HOME` is impermanent too. The upstream advice (notashelf) is to keep `$HOME`
persistent; this config deliberately does not, so expect to add persistence
rules for a few weeks as applications reveal where they keep state.

## Restoring a backup

Restore into `/persist/home/kita`, not `/home/kita` — the latter is a bind-mount
target and gets wiped. Directories that were top-level in the archive restore
under `/persist/home/kita/work/<project>` to match the persistence list above.

Bring the tunnel up first. The full procedure ships with the backup, not here.

## Validation

The config is checked without installing:

```bash
nix eval .#nixosConfigurations.wintermute.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.wintermute.config.system.build.diskoScript.drvPath
nix eval .#nixosConfigurations.iso-builder.config.system.build.isoImage.drvPath
```

All three evaluate clean. That proves the configuration is coherent — it does
not prove the machine boots, which only an install can.
