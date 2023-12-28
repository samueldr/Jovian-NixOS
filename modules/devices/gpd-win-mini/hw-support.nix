{ config, lib, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkForce
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.devices.gpd-win-mini;
in
{
  options = {
    jovian.devices.gpd-win-mini = {
      enableDefaultSysctlConfig = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.gpd-win-mini.enable";
        type = types.bool;
        description = ''
          Whether to enable stock SteamOS sysctl configs.
        '';
      };
      enableDefaultCmdlineConfig = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.gpd-win-mini.enable";
        type = types.bool;
        description = ''
          Whether to enable stock SteamOS kernel command line flags.
        '';
      };
      enableDefaultStage1Modules = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.gpd-win-mini.enable";
        type = types.bool;
        description = ''
          Whether to enable essential device-specific kernel modules in initrd.
        '';
      };
      enableProductSerialAccess = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.gpd-win-mini.enable";
        type = types.bool;
        description = lib.mdDoc ''
          > Loosen the product_serial node to `440 / root:wheel`, rather than `400 / root:root`
          > to allow the physical users to read S/N without auth.
          — holo-dmi-rules 1.0
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      # Firmware is required in stage-1 for early KMS.
      hardware.enableRedistributableFirmware = true;
    })
    (mkIf (cfg.enableProductSerialAccess) {
      systemd.tmpfiles.rules = [
        "z /sys/class/dmi/id/product_serial 440 root wheel - -"
      ];
    })
    (mkIf (cfg.enableDefaultStage1Modules) {
      boot.initrd.kernelModules = [
        "hid-generic"

        # Touch
        "hid-multitouch"
        "i2c-hid-acpi"
        # Those are built-in, but would be needed otherwise for touch.
        #"i2c-designware-core"
        #"i2c-designware-platform"

        # Gamepad
        "usbhid"
      ];
      boot.initrd.availableKernelModules = [
        "nvme"
        "sdhci"
        "sdhci_pci"
        "cqhci"
        "mmc_block"
      ];
    })
    (mkIf (cfg.enable) {
      jovian.steam.environment = {
          STEAM_ENABLE_DYNAMIC_BACKLIGHT = "0";
          STEAM_ENABLE_FAN_CONTROL = "0";
      };
    })
  ];
}
