import ./disko-config.nix {
  luksKeyFile = null;
  swapSize = "16G";

  enrollFido2 = true;
}
