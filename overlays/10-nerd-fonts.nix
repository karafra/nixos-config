self: super: {
  nerd-fonts = super.nerd-fonts // {
    fira-code = super.nerd-fonts.fira-code;
    jetbrains-mono = super.nerd-fonts.jetbrains-mono;
  };
}
