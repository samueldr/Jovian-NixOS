{ config, lib, ... }:

let
  inherit (lib)
    literalExpression
    mkIf
    mkOption
    mkMerge
    types
  ;
  cfg = config.jovian.devices.gpd-win-mini;
in
{
  options = {
    jovian.devices.gpd-win-mini = {
      enableEarlyModesetting = mkOption {
        default = cfg.enable;
        defaultText = literalExpression "config.jovian.devices.gpd-win-mini.enable";
        type = types.bool;
        description = ''
          Whether to enable early kernel modesetting.
        '';
      };
      enableXorgRotation = mkOption {
        default = cfg.enable;
        defaultText = literalExpression "config.jovian.devices.gpd-win-mini.enable";
        type = types.bool;
        description = ''
          Whether to configure the panel rotation for X11.
        '';
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enableEarlyModesetting {
      boot.initrd.kernelModules = [
        "amdgpu"
      ];
    })
    (mkIf cfg.enableXorgRotation {
      environment.etc."X11/xorg.conf.d/90-gpd-win-mini.conf".text = ''
        Section "Monitor"
          Identifier     "eDP-1"
          Option         "Rotate"    "right"
        EndSection

        Section "InputClass"
          Identifier "GPD Win Mini main display touch screen"
          MatchIsTouchscreen "on"
          MatchDevicePath    "/dev/input/event*"
          MatchDriver        "libinput"

          # 90° Clock-wise
          Option "CalibrationMatrix" "0 1 0 -1 0 1 0 0 1"
        EndSection
      '';
    })
  ]);
}

