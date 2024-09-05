# https://www.reddit.com/r/NixOS/comments/1b56jdx/simple_nix_function_for_wrapping_executables_with/
pkgs: {
  name ? "firejail-wrapper",
  executable,
  desktop ? null,
  profile ? null,
  extraArgs ? [],
}:
pkgs.runCommand name
{
  preferLocalBuild = true;
  allowSubstitutes = false;
  meta.priority = -1; # take precedence over non-firejailed versions
}
(
  let
    firejailArgs = pkgs.lib.concatStringsSep " " (
      extraArgs ++ (pkgs.lib.optional (profile != null) "--profile=${toString profile}")
    );
  in
    ''
      command_path="$out/bin/$(basename ${executable})-jailed"
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      cat <<'_EOF' >"$command_path"
      #! ${pkgs.runtimeShell} -e
      exec /run/wrappers/bin/firejail ${firejailArgs} -- ${toString executable} "\$@"
      _EOF
      chmod 0755 "$command_path"
    ''
    + pkgs.lib.optionalString (desktop != null) ''
      substitute ${desktop} $out/share/applications/$(basename ${desktop}) \
        --replace ${executable} "$command_path"
    ''
)
