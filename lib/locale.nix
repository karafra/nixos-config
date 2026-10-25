{ }:

let
  keyboardLayout = { id, name }: {
    InputSourceKind = "Keyboard Layout";
    "KeyboardLayout ID" = id;
    "KeyboardLayout Name" = name;
  };
in
{
  preferences = { languages, layout }: {
    NSGlobalDomain.AppleLanguages = languages;
    "com.apple.HIToolbox" = {
      AppleEnabledInputSources = [
        {
          "Bundle ID" = "com.apple.CharacterPaletteIM";
          InputSourceKind = "Non Keyboard Input Method";
        }
        (keyboardLayout layout)
      ];
      AppleSelectedInputSources = [ (keyboardLayout layout) ];
    };
  };
}
