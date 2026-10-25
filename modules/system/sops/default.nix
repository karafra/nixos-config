{ ... }:

{
  sops.defaultSopsFile = ../../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  sops.secrets."data/git_email" = { };
  sops.secrets."data/ssh_public_key" = { };
}
