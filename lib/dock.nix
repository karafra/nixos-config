{ lib }:

{
  # Wraps an app path in the tile structure the macOS Dock expects.
  app = path: {
    tile-type = "file-tile";
    tile-data.file-data = {
      _CFURLString = "file://${lib.replaceStrings [ " " ] [ "%20" ] path}";
      _CFURLStringType = 0;
    };
  };
}
