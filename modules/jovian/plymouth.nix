# XXX is this the right namespacing?
# TODO: conditionals
{ pkgs, ... }:

{
  config = {
    # jovian.steam.updater.splash = "jovian";
    # boot.plymouth.theme = "jovian";
    # boot.plymouth.themePackages = [
    #   pkgs.jovian-plymouth
    # ];
    # # *sigh* only required for other themes, bgrt works intrinsically...
    # # image scaling is all but extremely broken in plymouth.
    # boot.plymouth.extraConfig = ''
    #   DeviceScale=1
    # '';

    jovian.steam.updater.splash = "bgrt";
    boot.plymouth.theme = "bgrt";
    # TODO: remove the nixos logo / watermark (since anyway it's badly scaled)

    systemd.services.plymouth-deactivate = {
      enable = true;
      after = [
        "plymouth-start.service"
        "systemd-user-sessions.service"
      ];
      before = [
        # ???
        #"getty@tty1.service"
      ];
      serviceConfig = {
        type = "oneshot";
        ExecStart = "${pkgs.plymouth}/bin/plymouth deactivate";
        TimeoutSec = 2;
        RemainAfterExit = true;
      };
    };
    systemd.services.greetd = {
      unitConfig = {
        Wants = [
          "plymouth-deactivate.service"
        ];
        After = [
          "plymouth-deactivate.service"
        ];
        Conflicts = [
          "plymouth-quit.service"
          "plymouth-quit-wait.service"
        ];
      };
    };
  };
}
