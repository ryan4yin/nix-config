{
  config,
  lib,
  myvars,
  pkgs,
  ...
}:
# Native mihomo core + metacubexd dashboard, replacing the Clash Verge GUI: the
# GUI crashed (SIGFPE) and reopened a fake-IP leak window on every core restart.
#
# The config stays OUT of the Nix store (it holds subscription URLs and the
# controller secret) and reaches the service through systemd's LoadCredential.
# This module only wires up the service; generate the file with ./generate.nu.
# See README.md for usage and the routing notes, in particular the IPv6
# condition: the fake-ip v6 pool needs a line whose IPv6 actually works, and
# mihomo has no reachability probe to notice when the line loses it.
let
  cfg = config.modules.networking.mihomo;
  configFile = "${config.users.users.${myvars.username}.home}/.config/mihomo/config.yaml";
  host = config.networking.hostName;

  # generate.nu keeps the same directory in a constant; the host's preservation
  # entry (tmpfs-root hosts) reads both names from the options below.
  profilesDir = cfg.profilesDir;
  profilesGroup = cfg.profilesGroup;

  # 2750, not 2770: the owner (the generator) writes, the mihomo group only reads.
  # A group-writable directory would let a compromised core replace its own
  # provider files, and unlike config.yaml those copies are not re-injected on
  # restart, so the tampering would survive. Setgid makes the copies inherit the
  # group without anyone adding the human user to it.
  profilesDirMode = "2750";

  # metacubexd hardcodes its tab title ("MetaCubeXD") in the SPA and exposes no
  # config hook, so dashboards on different hosts look identical. Append the
  # hostname: patch the static <title>, then re-apply it from config.js because
  # Nuxt's useHead rewrites document.title on every route change. config.js is
  # metacubexd's post-build customization point (and is excluded from the PWA
  # precache), so this survives version bumps — unlike patching its hashed,
  # minified JS.
  webui = pkgs.runCommandLocal "metacubexd-${host}" { } ''
    cp -r ${pkgs.metacubexd} $out
    chmod -R u+w $out
    substituteInPlace $out/index.html $out/200.html $out/404.html \
      --replace '<title>MetaCubeXD</title>' '<title>MetaCubeXD · ${host}</title>'
    cat >> $out/config.js <<'EOF'

    ;(function () {
      var suffix = ' · ${host}'
      var apply = function () {
        var title = document.querySelector('title')
        if (title && title.textContent.indexOf(suffix) === -1) {
          title.textContent += suffix
        }
      }
      var head = document.head || document.documentElement
      new MutationObserver(apply).observe(head, { subtree: true, childList: true, characterData: true })
      apply()
    })()
    EOF
  '';
in
{
  options.modules.networking.mihomo = {
    enable = lib.mkEnableOption "the native Mihomo core with TUN and a local web UI";

    # Internal: one home for the two names the unit and the host's preservation
    # entry both need. generate.nu repeats the directory in a constant.
    profilesDir = lib.mkOption {
      type = lib.types.str;
      internal = true;
      default = "/var/lib/mihomo-profiles";
      description = ''
        Directory holding the local proxy-provider node lists, which config.yaml
        references by path. Never under $HOME: ProtectHome=true hides /home from
        the unit.
      '';
    };
    profilesGroup = lib.mkOption {
      type = lib.types.str;
      internal = true;
      default = "mihomo-profiles";
      description = ''
        Supplementary group allowed to read `profilesDir`. It has no human
        members: membership is the access, so never add an unrelated unit to it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      package = pkgs.mihomo;
      inherit configFile;
      inherit webui;
      tunMode = true;
    };

    # The config deliberately stays out of the store, under the user's home. On
    # tmpfs-root hosts that path is a persistent bind mount, so make the service
    # wait for it: otherwise activation can start mihomo before the mount is up
    # and fail with "Failed to set up credentials: No such file or directory".
    systemd.services.mihomo.unitConfig.RequiresMountsFor = builtins.dirOf configFile;

    # The profiles directory is a preservation bind mount on those hosts, so order
    # after the preservation target instead of RequiresMountsFor it: when the mount
    # is missing the unit should still start and log an empty provider, not fail to
    # start at all.
    systemd.services.mihomo.unitConfig.After = [ "preservation.target" ];

    # Force the TUN's v6 address up: left to itself mihomo skips the v6 half when
    # no NIC has an IPv6 address at startup, yet still installs its strict-route v6
    # blackhole, which locks the host out of IPv6. Upstream knob (`inet6-address`,
    # meta-docs tun.md); the full chain is WA-030.
    #
    # SAFE_PATHS: the core reads a proxy-provider `path` only below its `-d`
    # HomeDir or below a SAFE_PATHS entry, and profilesDir is neither.
    systemd.services.mihomo.serviceConfig.Environment = [
      "SKIP_SYSTEM_IPV6_CHECK=1"
      "SAFE_PATHS=${profilesDir}"
    ];

    # The node lists carry uuids and keys, so the group -- not world-readable
    # files -- is what lets the DynamicUser unit read the 0640 copies.
    users.groups.${profilesGroup} = { };
    systemd.services.mihomo.serviceConfig.SupplementaryGroups = [ profilesGroup ];

    # `+` runs as root, outside the unit sandbox. tmpfiles rules only run at boot
    # and a switch restarts mihomo, so the directory is prepared on every start.
    systemd.services.mihomo.serviceConfig.ExecStartPre =
      "+${pkgs.writeShellScript "mihomo-profiles-dir" ''
        mkdir -p ${profilesDir}
        chown ${myvars.username}:${profilesGroup} ${profilesDir}
        chmod ${profilesDirMode} ${profilesDir}
      ''}";
  };
}
