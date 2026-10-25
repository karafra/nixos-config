{ lib }:

{
  app = path: {
    tile-type = "file-tile";
    tile-data.file-data = {
      _CFURLString = "file://${lib.replaceStrings [ " " ] [ "%20" ] path}";
      _CFURLStringType = 0;
    };
  };
}
