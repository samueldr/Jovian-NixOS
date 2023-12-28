{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.gpd-win-mini;
in
{
  imports = [
    ./graphical.nix
    ./hw-support.nix
    ./kernel.nix
  ];
  options = {
    jovian.devices.gpd-win-mini = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GPD Win Mini specific configurations.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    jovian.hardware.has = {
      amd.gpu = true;
    };
  };
}
