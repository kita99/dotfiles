let
  palette = {
    base03 = "#002b36";
    base02 = "#073642";
    base01 = "#586e75";
    base00 = "#657b83";
    base0 = "#839496";
    base1 = "#93a1a1";
    base2 = "#eee8d5";
    base3 = "#fdf6e3";

    yellow = "#b58900";
    orange = "#cb4b16";
    red = "#dc322f";
    magenta = "#d33682";
    violet = "#6c71c4";
    blue = "#268bd2";
    cyan = "#2aa198";
    green = "#859900";
  };

  accents = {
    accent = palette.orange;
    urgent = palette.magenta;
    indicator = palette.violet;
  };
in
{
  inherit palette;

  dark = accents // {
    bg = palette.base03;
    bgAlt = palette.base02;
    fg = palette.base0;
    fgAlt = palette.base1;
    dim = palette.base01;
  };

  light = accents // {
    bg = palette.base3;
    bgAlt = palette.base2;
    fg = palette.base00;
    fgAlt = palette.base01;
    dim = palette.base1;
  };
}
