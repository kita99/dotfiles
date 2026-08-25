{ pkgs, ... }:

{
  environment.systemPackages = [ (pkgs.callPackage ../../pkgs/impermanence-diff.nix { }) ];
}
