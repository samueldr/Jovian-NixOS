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
    # XXX remapL4/R4 option
    {
      #
      # $ sudo lsinput 
      # ...
      # 6: 2f24:0135 USB    usb-0000:63:00.3   Mouse for Windows      KEY REL MSC     
      # 7: 2f24:0135 USB    usb-0000:63:00.3   Mouse for Windows      KEY MSC LED     
      # ...
      #
      # $ sudo input-events 7
      # /dev/input/event7
      #    id   : 2f24:0135, USB, v272
      #    phys : "usb-0000:63:00.3-3/input1"
      #    name : "  Mouse for Windows"
      #    KEY  : [ 163 codes ]
      #    MSC  : SCAN
      #    LED  : NUML CAPSL SCROLLL
      # 
      # waiting for events
      # 22:55:19.447941: MSC SCAN 458824
      # 22:55:19.447941: KEY PAUSE pressed
      # 22:55:19.447941: SYN code=0 value=0
      # 22:55:19.703600: KEY PAUSE pressed
      # 22:55:19.703600: SYN code=0 value=1
      # 22:55:19.737688: KEY PAUSE pressed
      # 22:55:19.737688: SYN code=0 value=1
      # 22:55:19.743950: MSC SCAN 458824
      # 22:55:19.743950: KEY PAUSE released
      # 22:55:19.743950: SYN code=0 value=0
      # 22:55:19.915968: MSC SCAN 458822
      # 22:55:19.915968: KEY SYSRQ pressed
      # 22:55:19.915968: SYN code=0 value=0
      # 22:55:20.167337: KEY SYSRQ pressed
      # 22:55:20.167337: SYN code=0 value=1
      # 22:55:20.201343: KEY SYSRQ pressed
      # 22:55:20.201343: SYN code=0 value=1
      # 22:55:20.211964: MSC SCAN 458822
      # 22:55:20.211964: KEY SYSRQ released
      # 22:55:20.211964: SYN code=0 value=0
      #
      # ~ $ cat /sys/class/input/event{6,7}/device/modalias 
      # input:b0003v2F24p0135e0110-e0,1,2,4,k110,111,112,113,114,r0,1,8,B,am4,lsfw
      # input:b0003v2F24p0135e0110-e0,1,4,11,14,k71,72,73,74,75,77,79,7A,7B,7C,7D,7E,7F,80,81,82,83,84,85,86,87,88,89,8A,8C,8E,96,98,9E,9F,A1,A3,A4,A5,A6,AD,B0,B1,B2,B3,B4,B7,B8,B9,BA,BB,BC,BD,BE,BF,C0,C1,C2,F0,ram4,l0,1,2,sfw
      #
      # Scancode values:
      #  - https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
      #
      # QAM as BTN_BASE ⇒ https://github.com/Jovian-Experiments/linux/blob/b9bc2d44db5b6ea54333d20a02de16780e41acb9/drivers/hid/hid-steam.c#L1565C12-L1565C20
      # BTN_TRIGGER_HAPPY1 for L4...
      services.udev.extraHwdb = ''
        # 70046 → L4 (99; SYSRQ)  → F21
        # 70048 → R4 (119; PAUSE) → F22
        evdev:input:b0003v2F24p0135e0110*
         KEYBOARD_KEY_70046=key_f21
         KEYBOARD_KEY_70048=key_f22
      '';
    }
  ];
}
