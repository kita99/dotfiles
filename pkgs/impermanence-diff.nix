{ writeShellApplication
, btrfs-progs
, util-linux
, coreutils
, findutils
, gnugrep
, gnused
}:

writeShellApplication {
  name = "impermanence-diff";
  runtimeInputs = [ btrfs-progs util-linux coreutils findutils gnugrep gnused ];
  text = ''
    set -euo pipefail

    DEVICE="''${DEVICE:-/dev/mapper/cryptroot}"
    INDEX=0            # 0 = most recent retained root
    TOP=25             # how many candidates to show
    SHOW_ALL=0

    usage() {
      cat <<'EOF'
    impermanence-diff - show state created by a previous boot and lost on reboot

      -n INDEX   which retained root (0 = most recent, default)
      -t N       show top N candidates (default 25)
      -a         do not filter known-noise paths
      -l         list retained roots and exit
      -m PATH    use an already-mounted top-level subvolume instead of
                 mounting one (also makes the logic testable offline)
      -h         help

    Compares a retained root against @root-blank. Anything present in the
    former and absent from the latter was created during that session and
    did not survive. Run as root.
    EOF
    }

    LIST_ONLY=0
    PREMOUNTED=""
    while getopts "n:t:alm:h" opt; do
      case "$opt" in
        n) INDEX="$OPTARG" ;;
        t) TOP="$OPTARG" ;;
        a) SHOW_ALL=1 ;;
        l) LIST_ONLY=1 ;;
        m) PREMOUNTED="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
      esac
    done

    if [ -n "$PREMOUNTED" ]; then
      MNT="$PREMOUNTED"
      cleanup() { :; }
    else
      if [ "$(id -u)" -ne 0 ]; then
        echo "must run as root (needs to mount the top-level subvolume)" >&2
        exit 1
      fi
      MNT=$(mktemp -d)
      cleanup() { umount "$MNT" 2>/dev/null || true; rmdir "$MNT" 2>/dev/null || true; }
      mount -o subvol=/,ro "$DEVICE" "$MNT"
    fi
    trap cleanup EXIT

    if [ ! -d "$MNT/old_roots" ]; then
      echo "no old_roots on $DEVICE - has this system rebooted since install?" >&2
      exit 1
    fi

    mapfile -t ROOTS < <(find "$MNT/old_roots" -mindepth 1 -maxdepth 1 -type d | sort -r)
    if [ "''${#ROOTS[@]}" -eq 0 ]; then
      echo "old_roots is empty - nothing retained yet" >&2
      exit 1
    fi

    if [ "$LIST_ONLY" -eq 1 ]; then
      echo "retained roots (newest first):"
      i=0
      for r in "''${ROOTS[@]}"; do
        printf "  [%d] %s\n" "$i" "$(basename "$r")"
        i=$((i+1))
      done
      exit 0
    fi

    if [ "$INDEX" -ge "''${#ROOTS[@]}" ]; then
      echo "only ''${#ROOTS[@]} retained root(s); index $INDEX out of range" >&2
      exit 1
    fi

    OLD="''${ROOTS[$INDEX]}"
    BLANK="$MNT/@root-blank"
    [ -d "$BLANK" ] || { echo "@root-blank missing - cannot compare" >&2; exit 1; }

    echo "comparing $(basename "$OLD") against the pristine @root-blank"
    echo

    noise_filter() {
      if [ "$SHOW_ALL" -eq 1 ]; then cat; return; fi
      grep -vE '^/(tmp|run|proc|sys|dev|var/tmp|var/cache|var/log)(/|$)' \
        | grep -vE '^/(nix|persist)(/|$)' \
        | grep -vE '/\.cache(/|$)' \
        | grep -vE '^/var/lib/systemd/(random-seed|timesync)' \
        | grep -vE '^/etc/(resolv\.conf|machine-id|ssh/ssh_host)' || true
    }

    LIST=$(mktemp)
    trap 'cleanup; rm -f "$LIST"' EXIT
    find "$OLD" -xdev -type f -printf '%P\n' 2>/dev/null \
      | while IFS= read -r rel; do
          [ -e "$BLANK/$rel" ] || printf '/%s\n' "$rel"
        done \
      | noise_filter > "$LIST"

    TOTAL=$(wc -l < "$LIST")
    if [ "$TOTAL" -eq 0 ]; then
      echo "nothing lost that is worth persisting - the session created no new state"
      exit 0
    fi

    echo "$TOTAL file(s) created during that session and destroyed on reboot"
    echo
    echo "grouped by directory (most files first):"
    sed 's|/[^/]*$||' "$LIST" | sort | uniq -c | sort -rn | head -"$TOP" \
      | sed 's/^/  /'

    echo
    echo "largest individual losses:"
    while IFS= read -r f; do
      [ -f "$OLD$f" ] && printf '%s\t%s\n' "$(stat -c %s "$OLD$f" 2>/dev/null || echo 0)" "$f"
    done < "$LIST" | sort -rn | head -10 \
      | while IFS=$'\t' read -r sz path; do
          printf '  %8s  %s\n' "$(numfmt --to=iec "$sz")" "$path"
        done

    echo
    echo "suggested persistence rules - paste into modules/nixos/impermanence.nix:"
    echo
    sed 's|/[^/]*$||' "$LIST" | sort -u \
      | grep -E '^/home/[^/]+/' \
      | sed -E 's|^/home/[^/]+/||' \
      | awk -F/ '
          $1 == ".local" && NF >= 3 { print $1"/"$2"/"$3; next }
          $1 == ".config" && NF >= 2 { print $1"/"$2; next }
          NF >= 2 { print $1"/"$2; next }
          { print $1 }
        ' \
      | sort -u | head -15 \
      | sed 's|^|      "|; s|$|"|' \
      | { echo "    users.kita.directories = ["; cat; echo "    ];"; }

    sed 's|/[^/]*$||' "$LIST" | sort -u \
      | grep -vE '^/home/' \
      | awk -F/ '
          $2 == "var" && $3 == "lib" && NF >= 4 { print "/"$2"/"$3"/"$4; next }
          NF >= 3 { print "/"$2"/"$3; next }
          { print "/"$2 }
        ' \
      | sort -u | head -15 \
      | sed 's|^|      "|; s|$|"|' \
      | { echo "    directories = ["; cat; echo "    ];"; }

    echo
    echo "recover a specific file with:"
    echo "  sudo mount -o subvol=/,ro $DEVICE /mnt"
    echo "  cp /mnt/old_roots/$(basename "$OLD")/<path> <destination>"
  '';
}
