{ pkgs, lib, config, inputs, ... }:

let
  pkgs-stable = import inputs.nixpkgs-stable { system = pkgs.stdenv.system; };
in
{
  env.GREET = "Phoenix Duskmoon";
  env.DUSKMOON_NATIVE_MODE = "precompiled";
  env.HOLOGRAM_START = "1";
  env.NPM_EX_ALLOWED_REGISTRIES =
    "https://npm.gsmlg.dev,https://registry.npmjs.org,https://nexus.gsmlg.net";

  packages = with pkgs-stable; [
    git
    figlet
    lolcat
    watchman
  ] ++ lib.optionals stdenv.isLinux [
    inotify-tools
  ];

  languages.elixir.enable = true;
  languages.elixir.package = pkgs-stable.beam28Packages.elixir;

  languages.javascript.enable = true;

  scripts.hello.exec = ''
    figlet -w 120 $GREET | lolcat
  '';

  enterShell = ''
    hello
  '';

}
