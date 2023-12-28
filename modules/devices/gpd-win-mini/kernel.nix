{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;

  cfg = config.jovian.devices.gpd-win-mini;

  # We can't use `config.boot.kernelPackages.kernelOlder` anymore.
  # See: https://github.com/NixOS/nixpkgs/pull/272029#issuecomment-1928608297
  # This is a close enough approximation given our `mkDefault`. :(
  currentKernel = pkgs.linuxPackages_latest;
in
{
  options = {
    jovian.devices.gpd-win-mini = {
      enableKernelPatches = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.gpd-win-mini.enable";
        description = ''
          Whether to apply kernel patches if available.
        '';
      };
    };
  };
  config = mkIf (cfg.enableKernelPatches) (mkMerge [
    {
      warnings = lib.optional (currentKernel.kernelOlder "6.6") ''
        The kernel patches for the GPD Win Mini were authored starting with kernel 6.6.

        Use `boot.kernelPackages = pkgs.linuxPackages_latest` to pick-up better support for the hardware.
      '';

      boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

      # Patch will be present in 6.9
      boot.kernelPatches = mkIf (currentKernel.kernelAtLeast "6.6" && currentKernel.kernelOlder "6.8.6") [
        {
          name = "gpd-win-mini-orientation";
          patch = pkgs.fetchpatch {
            url = "https://lore.kernel.org/all/20231222030149.3740815-2-samuel@dionne-riel.com/raw";
            hash = "sha256-ZqKx/PzyeY6t9ATPhEG4g1aSVW8msBNmxywA57+GIi0=";
          };
        }
      ];
    }
  ]);
}
