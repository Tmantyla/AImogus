{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = with pkgs; [godot gdtoolkit_4];
}
