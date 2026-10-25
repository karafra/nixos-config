{ lib }:

{
  app = path: {
    tile-type = "file-tile";
    tile-data = {
      file-data = {
        _CFURLString = "file://${lib.replaceStrings [ " " ] [ "%20" ] path}/";
        _CFURLStringType = 15;
      };
      file-label = lib.removeSuffix ".app" (baseNameOf path);
      file-type = 41;
    };
  };
}
